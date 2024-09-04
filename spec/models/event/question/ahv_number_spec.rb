# frozen_string_literal: true

#  Copyright (c) 2012-2020, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# == Schema Information
#
# Table name: event_questions
#
#  id               :integer          not null, primary key
#  event_id         :integer
#  question         :string
#  choices          :string
#  multiple_choices :boolean          default(FALSE)
#  required         :boolean
#

require "spec_helper"

describe Event::Question::AhvNumber do
  let(:event) { events(:top_course) }
  let(:participation) { event.participations.build }
  subject(:question) { described_class.new(question: "AHV-Number", disclosure: :optional, event: event) }

  describe "Event::Answer" do
    subject(:answer) { question.answers.build(participation: participation) }

    it "accepts empty answer when optional" do
      answer.answer = ""
      is_expected.to be_valid
    end

    it "accepts only real ahv-numbers" do
      answer.answer = "test"
      is_expected.not_to be_valid

      answer.answer = "756.1234.5678.91" # invalid checksum
      is_expected.not_to be_valid

      answer.answer = "756.1234.5678.97"
      is_expected.to be_valid
    end
  end
end
