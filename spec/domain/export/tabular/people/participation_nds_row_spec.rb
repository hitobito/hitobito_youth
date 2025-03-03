# encoding: utf-8

#  Copyright (c) 2012-2024, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Tabular::People::ParticipationNdsRow do

  let(:person) { nds_person }
  let(:participation) do
    Fabricate(:event_participation, person: person, event: events(:top_course))
  end

  let(:row) { Export::Tabular::People::ParticipationNdsRow.new(participation) }
  subject { row }

  it { expect(row.fetch(:j_s_number)).to eq '1695579' }
  it { expect(row.fetch(:last_name)).to eq 'Muster' }
  it { expect(row.fetch(:first_name)).to eq 'Peter' }
  it { expect(row.fetch(:birthday)).to eq '11.06.1980' }
  it { expect(row.fetch(:gender)).to eq 'm' }
  it { expect(row.fetch(:peid)).to be_nil }
  it { expect(row.fetch(:nationality_j_s)).to eq 'FL' }
  it { expect(row.fetch(:first_language)).to eq 'DE' }
  it { expect(row.fetch(:second_language)).to be_nil }
  it { expect(row.fetch(:street)).to eq 'Hauptstrasse' }
  it { expect(row.fetch(:housenumber)).to eq '33' }
  it { expect(row.fetch(:zip_code)).to eq '4000' }
  it { expect(row.fetch(:town)).to eq 'Basel' }
  it { expect(row.fetch(:country)).to eq 'CH' }
  it { expect(row.fetch(:phone_private)).to eq '+41 31 111 12 13' }
  it { expect(row.fetch(:phone_work)).to eq '+41 24 422 42 42' }
  it { expect(row.fetch(:phone_official)).to be_nil }
  it { expect(row.fetch(:email)).to eq 'foo@example.com' }
  it { expect(row.fetch(:email_official)).to be_nil }
  it { expect(row.fetch(:email_work)).to be_nil }

  context 'with nationality_j_s ANDERE' do
    let(:person) do
      p = nds_person
      p.update(nationality_j_s: 'ANDERE')
      p
    end

    it { expect(row.fetch(:nationality_j_s)).to eq 'ANDERE' }
  end

  describe 'j_s_number format' do
    before do
      person.j_s_number = '169-55-79'
    end

    it { expect(row.fetch(:j_s_number)).to eq '1695579' }
  end

  describe 'default nationality_j_s and country' do
    before do
      person.country = nil
      person.nationality_j_s = nil
    end

    it do
      expect(row.fetch(:country)).to eq 'CH'
      expect(row.fetch(:nationality_j_s)).to eq 'CH'
    end
  end

  describe 'ahv_number' do
    subject(:ahv_number) { row.fetch(:ahv_number) }
    let(:valid_ahv_number) { '756.1234.5678.97' }

    before do
      expect(person).to receive(:last_known_ahv_number).and_call_original
    end

    context "with ahv_number on participation" do
      it "calls #last_known_ahv_number and returns participation answer" do
        event = participation.event
        question = Event::Question::AhvNumber.create(disclosure: :required, question: "AHV?", event: event)
        answer = Event::Answer.find_by(question: question, participation: participation)
        answer.update!(answer: valid_ahv_number)
        is_expected.to eq(valid_ahv_number)
      end
    end
  end

  private

  def nds_person
    person = Fabricate(:person,
                       email: 'foo@example.com',
                       first_name: 'Peter',
                       last_name: 'Muster',
                       birthday: '11.06.1980',
                       gender: 'm',
                       j_s_number: '1695579',
                       street: 'Hauptstrasse',
                       housenumber: '33',
                       zip_code: '4000',
                       town: 'Basel',
                       country: 'CH',
                       nationality_j_s: 'FL')
    create_contactables(person)
    person
  end

  def create_contactables(person)
    Fabricate(:phone_number, contactable: person, label: 'Privat', number: '+41 31 111 12 13')
    Fabricate(:phone_number, contactable: person, label: 'Arbeit', number: '+41 24 422 42 42')
    Fabricate(:phone_number, contactable: person, label: 'Mobil', number: '+41 77 999 99 99')
    Fabricate(:phone_number, contactable: person, label: 'Fax', number: '+41 33 333 33 33')
  end

end
