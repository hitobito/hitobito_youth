# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Tabular::People::ParticipationsSportdb do

  let(:person) { sportdb_person }
  let(:participation) { Fabricate(:event_participation, person: person, event: events(:top_course)) }

  let(:list) { Export::Tabular::People::ParticipationsSportdb.new([participation]) }
  let(:row) { list.data_rows.first }

  it 'has all required cells in correct order' do
    expect(row[0]).to eq '1695579'
    expect(row[1]).to eq 1
    expect(row[2]).to eq 'Muster'
    expect(row[3]).to eq 'Peter'
    expect(row[4]).to eq '11.06.1980'
    expect(row[5]).to eq '756.1234.5678.97'
    expect(row[6]).to eq 'Hauptstrasse 33'
    expect(row[7]).to eq '4000'
    expect(row[8]).to eq 'Basel'
    expect(row[9]).to eq 'CH'
    expect(row[10]).to eq 'FL'
    expect(row[11]).to eq 'D'
  end

  it 'outputs optional empty values as nil, in order to not overwrite existing values in SPORTDB' do
    person.update(
        first_name: '',
        last_name: '',
        ahv_number: '',
        address: '',
        zip_code: '',
        town: '',
    )
    expect(row[2]).to eq nil
    expect(row[3]).to eq nil
    expect(row[5]).to eq nil
    expect(row[6]).to eq nil
    expect(row[7]).to eq nil
    expect(row[8]).to eq nil
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
                ahv_number: '756.1234.5678.97',
                address: 'Hauptstrasse 33',
                zip_code: '4000',
                town: 'Basel',
                country: 'CH',
                nationality_j_s: 'FL'
              )
  end
end
