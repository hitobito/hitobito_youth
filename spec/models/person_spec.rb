# encoding: utf-8

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Person do
  let(:top_leader) { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }

  describe '#nationality_j_s' do
    it 'accepts values CH FL ANDERE' do
      %w(CH FL ANDERE).each do |value|
        person = Person.new(last_name: 'dummy', nationality_j_s: value)
        expect(person).to be_valid
      end
    end

    it 'accepts blank and nil values' do
      expect(Person.new(last_name: 'dummy')).to be_valid
      expect(Person.new(last_name: 'dummy', nationality_j_s: '')).to be_valid
    end

    it 'rejects any other value' do
      expect(Person.new(last_name: 'dummy', nationality_j_s: 'other')).not_to be_valid
    end
  end

  describe '#last_known_ahv_number' do
    let(:valid_ahv_number) { '756.1234.5678.97' }
    let(:person) { top_leader }
    subject(:last_known_ahv_number) { person.last_known_ahv_number }

    context "without any answers" do
      it 'falls back on the legacy ahv number' do
        person.ahv_number = valid_ahv_number
        is_expected.to eq(person.ahv_number)
      end
    end

    context "with answered questions of type Event::Question::AhvNumber" do
      let(:ahv_numbers) do
        %w[756.3720.9797.95 756.7774.5627.12 756.5137.2138.68]
      end
      let(:ahv_number_answers) do
        ahv_numbers.map.with_index do |ahv_number, i|
          participation = Fabricate(:event_participation, person: person)
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

  describe '#ahv_number' do
    it 'fails for malformatted ahv number' do
      person = Person.new
      person.ahv_number = 'malformed ahv'
      expect(person).to have(1).error_on(:ahv_number)
      expect(person.errors.messages[:ahv_number].first).to match(/gültigen Format/)
    end

    it 'succeeds for ahv number with correct format' do
      person = Person.new(last_name: 'dummy',
                          nationality_j_s: 'CH',
                          ahv_number: '756.1234.5678.97')
      expect(person).to be_valid
    end

    it 'fails for ahv number with wrong checksum' do
      person = Person.new(last_name: 'dummy',
                          nationality_j_s: 'CH',
                          ahv_number: '756.1234.5678.98')
      expect(person).to have(1).error_on(:ahv_number)
      expect(person.errors.messages[:ahv_number].first).to match(/gültige Prüfziffer/)
    end

    it 'can still change password even if stored ahv number is invalid' do
      person = Person.new(ahv_number: 'malformed', first_name: 'Jack')
      person.save(validate: false)

      expect do
        person.password = 'mynewsuperstrongpassword'
      end.to change(person, :valid?).from(false).to(true)
    end
  end

  describe 'people managers' do
    it 'does not allow for someone to be both manager and managed' do
      top_leader.managers = [bottom_member]
      top_leader.manageds = [Fabricate(:person)]

      expect(top_leader).to_not be_valid
    end

    it 'does not allow to manage someone who is manager' do
      bottom_member.manageds = [Fabricate(:person)]
      bottom_member.save

      top_leader.manageds = [bottom_member]

      expect(top_leader).to_not be_valid
    end

    it 'can provide a mail to a managed person' do
      managed = Fabricate(:person, email: nil)
      expect(managed).to_not be_nil
      expect(bottom_member).to be_valid_email

      managed.managers = [bottom_member]

      expect(managed).to be_valid_email
    end
  end
end
