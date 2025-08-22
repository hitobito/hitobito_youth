# encoding: utf-8

#  Copyright (c) 2012-2024, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Tabular::People::ParticipationsNdsCamp do

  let(:person) { sportdb_person }
  let(:valid_ahv_number) { '756.1234.5678.97'}
  let(:participation) do
    p = Fabricate(:event_participation, participant: person, event: events(:top_course))
    question = Event::Question::AhvNumber.create(disclosure: :required, question: "AHV?", event: events(:top_course))
    answer = Event::Answer.find_by(question: question, participation: p)
    answer.update!(answer: valid_ahv_number)

    p
  end

  let(:list) { Export::Tabular::People::ParticipationsNdsCamp.new([participation]) }
  let(:row) { list.data_rows.first }

  it 'has all required cells in correct order' do
    expect(row[0]).to eq '1695579'
    expect(row[1]).to eq 'Muster'
    expect(row[2]).to eq 'Peter'
    expect(row[3]).to eq '11.06.1980'
    expect(row[4]).to eq 'm'
    expect(row[5]).to eq '756.1234.5678.97'
    expect(row[6]).to be_nil
    expect(row[7]).to eq 'FL'
    expect(row[8]).to eq 'DE'
    expect(row[9]).to eq 'Hauptstrasse'
    expect(row[10]).to eq '33'
    expect(row[11]).to eq '4000'
    expect(row[12]).to eq 'Basel'
    expect(row[13]).to eq 'CH'
  end

  it 'outputs optional empty values as nil, in order to not overwrite existing values in SPORTDB' do
    person.update(
      j_s_number: '',
      street: '',
      housenumber: ''
    )
    expect(row[0]).to eq nil
    expect(row[9]).to eq nil
    expect(row[10]).to eq nil
  end

  private

  def sportdb_person
    Fabricate(:person,
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
  end
end
