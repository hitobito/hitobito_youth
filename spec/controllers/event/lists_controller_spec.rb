# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::ListsController do
  before { sign_in(person) }
  let(:person) { people(:top_leader) }

  context 'GET #bsv_export' do
    let(:rows) { response.body.split("\r\n") }

    it 'shows error if no filter params given' do
      get :bsv_export
      is_expected.to redirect_to(list_courses_path)
      expect(flash[:alert]).to eq 'Für den BSV Export muss mindestens ein Abschlussdatum (von/bis) angegeben werden.'
    end

    it 'shows error if date_from newer than date to' do
      get :bsv_export, date_from: '11.11.2015', date_to: '10.10.2015'
      is_expected.to redirect_to(list_courses_path)
      expect(flash[:alert]).to eq 'Abschlussdatum von kann nicht neuer als Abschlussdatum bis sein.'
    end

    #it 'exports all courses with kind fk within date range' do
      #Fabricate(:course, kind: event_kinds(:slk))
      #create_course('123', '01.01.2015', '03.01.2015')
      #create_course('124', '11.11.2015', '12.12.2015')

      #get :bsv_export, event_kinds: [event_kinds(:fk).id], date_from: '09.09.2015'
      #expect(response).to be_success
      #expect(rows.size).to eq(1)
      #expect(rows.first).to match(/^fiver42;/)
    #end

    #it 'exports all courses within date range' do
      #create_course('123', '01.01.2015', '03.01.2015')
      #create_course('124', '11.12.2015', '12.12.2015')
      #create_course('125', '06.06.2015', nil)
      #create_course('126', '06.06.2015', '08.06.2015', 'created')

      #get :bsv_export, date_from: '01.02.2015', date_to: '21.12.2015'
      #expect(response).to be_success
      #expect(rows.size).to eq(2)
      #expect(rows.first).to match(/^fiver42;;124;11.11.2015;/)
      #expect(rows.second).to match(/^fiver42;;125;06.06.2015;/)
    #end

  end

end

def create_course(number, date_from, date_to, state = 'closed')
  course = Fabricate(:course, kind: event_kinds(:fk), number: number, state: state)
  course.dates.destroy_all
  event_date = Fabricate(:event_date,
                          event: course,
                          start_at: Date.parse(date_from))
  event_date.update!(finish_at: Date.parse(date_to)) if date_to
  event_kinds(:fk).update!(vereinbarungs_id_fiver: 'fiver42')
end
