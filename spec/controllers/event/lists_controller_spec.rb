# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::ListsController do
  before { sign_in(person) }
  let(:person) { people(:top_leader) }
  let(:kind) { event_kinds(:fk) }

  context 'GET #bsv_export' do
    let(:rows) { response.body.split("\r\n") }

    it 'shows error if no filter params given' do
      get :bsv_export
      is_expected.to redirect_to(list_courses_path)
      expect(flash[:alert]).to eq 'Für den BSV Export muss mindestens ein Abschlussdatum (von/bis) angegeben werden.'
    end

    it 'shows error if date_from newer than date to' do
      get :bsv_export, bsv_export: { date_from: '11.11.2015', date_to: '10.10.2015' }
      is_expected.to redirect_to(list_courses_path)
      expect(flash[:alert]).to eq 'Abschlussdatum von kann nicht neuer als Abschlussdatum bis sein.'
    end

    it 'exports all courses with kind fk and date from' do
      create_course('123', '03.01.2015', '09.01.2015')
      create_course('124', '11.11.2015', '12.11.2015')

      get :bsv_export, bsv_export: { event_kinds: [kind.id], date_from: '09.09.2015' }
      expect(response).to be_success
      expect(rows.size).to eq(2)
      expect(rows.first).to match(/^Vereinbarung-ID-FiVer;Kurs-ID-FiVer;Kursnummer/)
      expect(rows.second).to match(/^fiver42;;124;11.11.2015;/)
    end

    it 'exports all courses with kind fk and date to' do
      create_course('123', '03.01.2015', '09.01.2015')
      create_course('124', '11.11.2015', '12.11.2015')

      get :bsv_export, bsv_export: { event_kinds: [kind.id], date_to: '09.09.2015' }
      expect(response).to be_success
      expect(rows.size).to eq(2)
      expect(rows.second).to match(/^fiver42;;123;03.01.2015;/)
    end

    it 'exports all courses within date range and state closed' do
      create_course('123', '01.01.2015', '03.01.2015')
      create_course('124', '11.11.2015', '12.12.2015')
      create_course('125', '06.06.2015', nil)
      create_course('126', '06.06.2015', '08.06.2015', 'created')

      get :bsv_export, bsv_export: { date_from: '01.02.2015', date_to: '21.12.2015' }
      expect(response).to be_success
      expect(rows.size).to eq(3)
      expect(rows.second).to match(/^fiver42;;125;06.06.2015;/)
      expect(rows.third).to match(/^fiver42;;124;11.11.2015;/)
    end

    it 'exports only courses of matching event kind' do
      create_course('123', '03.01.2015', '09.01.2015')
      create_course('124', '03.01.2015', '09.01.2015', 'closed', event_kinds(:glk))

      get :bsv_export, bsv_export: { event_kinds: [event_kinds(:glk).id], date_to: '09.09.2015' }
      expect(response).to be_success
      expect(rows.size).to eq(2)
      expect(rows.second).to match(/^fiver42;;124;03.01.2015;/)
    end

    it 'exports only courses of specific group' do
      create_course('123', '03.01.2015', '09.01.2015')
      create_course('124', '03.01.2015', '09.01.2015', 'closed', kind, groups(:top_layer))

      get :bsv_export, year: '2015', group_id: groups(:top_layer).id, bsv_export: { event_kinds: [kind.id], date_to: '09.09.2015' }
      expect(response).to be_success
      expect(rows.size).to eq(2)
      expect(rows.second).to match(/^fiver42;;124;03.01.2015;/)
    end
  end

end

def create_course(number, date_from, date_to, state = 'closed', event_kind = kind, group = groups(:top_group))
  course = Fabricate(:course, groups: [group], kind: event_kind, number: number, state: state)
  course.dates.destroy_all
  date_from = Date.parse(date_from) if date_from
  date_to = Date.parse(date_to) if date_to
  course.dates.create!(start_at: date_from, finish_at: date_to)
  event_kind.update!(vereinbarungs_id_fiver: 'fiver42')
end
