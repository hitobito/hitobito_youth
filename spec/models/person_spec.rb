# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Person do

  describe '#nationality_j_s' do
    it 'accepts values CH FL DIV' do
      %w(CH FL DIV).each do |value|
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

  describe '#ahv_number' do
    it 'fails for malformatted ahv number' do
      person = Person.new
      person.ahv_number = 'malformed ahv'
      expect(person).to have(1).error_on(:ahv_number)
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
    end

    it 'can still change password even if stored ahv number is invalid' do
      person = Person.new(ahv_number: 'malformed', first_name: 'Jack')
      person.save(validate: false)

      expect do
        person.password = 'mynewsuperstrongpassword'
      end.to change(person, :valid?).from(false).to(true)
    end

  end

end
