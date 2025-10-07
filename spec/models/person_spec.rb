#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require "spec_helper"

describe Person do
  let(:top_leader) { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }

  describe "#nationality_j_s" do
    it "accepts values CH FL ANDERE" do
      %w[CH FL ANDERE].each do |value|
        person = Person.new(last_name: "dummy", nationality_j_s: value)
        expect(person).to be_valid
      end
    end

    it "accepts blank and nil values" do
      expect(Person.new(last_name: "dummy")).to be_valid
      expect(Person.new(last_name: "dummy", nationality_j_s: "")).to be_valid
    end

    it "rejects any other value" do
      expect(Person.new(last_name: "dummy", nationality_j_s: "other")).not_to be_valid
    end
  end

  describe "#last_known_ahv_number" do
    let(:valid_ahv_number) { "756.1234.5678.97" }
    let(:person) { top_leader }
    subject(:last_known_ahv_number) { person.last_known_ahv_number }

    context "with answered questions of type Event::Question::AhvNumber" do
      let(:ahv_numbers) do
        %w[756.3720.9797.95 756.7774.5627.12 756.5137.2138.68]
      end
      let(:ahv_number_answers) do
        ahv_numbers.map.with_index do |ahv_number, i|
          participation = Fabricate(:event_participation, participant: person)
          event = participation.event
          question = Event::Question::AhvNumber.create(disclosure: :required, question: "AHV?", event: event)
          answer = Event::Answer.find_by(question: question, participation: participation)
          answer.update!(answer: ahv_number)
          participation.touch(time: (i + 1).months.ago)
          answer
        end
      end

      it "uses the last updated answer" do
        ahv_number_answers
        is_expected.to eq(ahv_numbers.last)
      end

      it "uses only specified participation_id" do
        expected_answer = ahv_number_answers.first
        expect(person.last_known_ahv_number(expected_answer.participation_id)).to eq(expected_answer.answer)
      end
    end
  end
end
