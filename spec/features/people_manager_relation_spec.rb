# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe 'PeopleManagerRelation', js: true do
  let(:top_leader) { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }
  let(:bottom_leader) { people(:bottom_leader) }
  let(:root) { people(:root) }
  before { sign_in(user) }

  describe 'person edit' do
    context 'as top_leader' do
      let(:user) { top_leader }

      it 'shows permission denied instead of manager form for self' do
        visit edit_group_person_path(group_id: top_leader.primary_group_id, id: top_leader)

        expect(page).to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'
      end

      it 'establishes manager relation' do
        visit edit_group_person_path(group_id: bottom_leader.primary_group_id, id: bottom_leader)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'

        find('a.add_nested_fields[data-association="people_managers"]').click

        find('#people_managers_fields input').set('Bottom Mem')

        expect(page).to have_content 'Bottom Member'

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.to change { PeopleManager.count }.by(1)
          .and change { PaperTrail::Version.count }.by(2)

        expect(page).to have_content 'Verwalter*in Bottom Member hinzugefügt.'
        find('dd a', text: 'Bottom Member').click

        expect(current_path).to eq(person_path(id: bottom_member.id))

        expect(page).to have_content 'Top Leader'
      end

      it 'establishes managed relation' do
        visit edit_group_person_path(group_id: bottom_leader.primary_group_id, id: bottom_leader)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'

        find('a.add_nested_fields[data-association="people_manageds"]').click

        find('#people_manageds_fields input').set('Bottom Mem')

        expect(page).to have_content 'Bottom Member'

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.to change { PeopleManager.count }.by(1)
          .and change { PaperTrail::Version.count }.by(2)

        expect(page).to have_content 'Kind Bottom Member hinzugefügt.'
        find('dd a', text: 'Bottom Member').click

        expect(current_path).to eq(person_path(id: bottom_member.id))

        expect(page).to have_content 'Top Leader'
      end

      it 'can not establish both managed and manager relation' do
        visit edit_group_person_path(group_id: bottom_leader.primary_group_id, id: bottom_leader)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'

        find('a.add_nested_fields[data-association="people_manageds"]').click

        find('#people_manageds_fields input').set('Bottom Mem')

        expect(page).to have_content 'Bottom Member'

        find('.typeahead.dropdown-menu li').click

        find('a.add_nested_fields[data-association="people_managers"]').click

        find('#people_managers_fields input').set('Bottom Lea')

        expect(page).to have_content 'Bottom Leader'

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.not_to change { PeopleManager.count }

        expect(page).to have_content('Kann nicht sowohl Verwalter*innen als auch Kinder haben.')
      end

      it 'can not establish manager relation to someone who is managed' do
        bottom_leader.managers = [top_leader]

        visit edit_group_person_path(group_id: bottom_member.primary_group_id, id: bottom_member)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'

        find('a.add_nested_fields[data-association="people_managers"]').click

        find('#people_managers_fields input').set('Bottom Lea')

        expect(page).to have_content 'Bottom Leader'

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.to_not change { PeopleManager.count }

        expect(page).to have_content 'Verwalter*in konnte nicht hinzugefügt werden, da er/sie bereits verwaltet wird.'
      end

      it 'can not establish managed relation to someone who is manager' do
        bottom_leader.manageds = [top_leader]

        visit edit_group_person_path(group_id: bottom_member.primary_group_id, id: bottom_member)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'

        find('a.add_nested_fields[data-association="people_manageds"]').click

        find('#people_manageds_fields input').set('Bottom Lea')

        expect(page).to have_content 'Bottom Leader'

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.to_not change { PeopleManager.count }

        expect(page).to have_content 'Kind konnte nicht hinzugefügt werden, da es bereits Verwalter*in ist.'
      end

      it 'finds person without roles for manager option' do
        person_without_roles = Fabricate(:person, first_name: 'Bob', last_name: 'Foo')

        visit edit_group_person_path(group_id: bottom_member.primary_group_id, id: bottom_member)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'

        find('a.add_nested_fields[data-association="people_managers"]').click

        find('#people_managers_fields input').set('Bob F')

        expect(page).to have_content 'Bob Foo'

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.to change { PeopleManager.count }.by(1)
          .and change { PaperTrail::Version.count }.by(2)

        expect(page).to have_content "Verwalter*in #{person_without_roles.person_name} hinzugefügt."
        find('dd a', text: 'Bob Foo').click

        expect(current_path).to eq(person_path(id: person_without_roles))
      end

      it 'can not add same manager twice' do
        bottom_member.managers = [bottom_leader]

        visit edit_group_person_path(group_id: bottom_member.primary_group_id, id: bottom_member)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'
        expect(page).to have_content 'Bottom Leader'

        find('a.add_nested_fields[data-association="people_managers"]').click

        find('#people_managers_fields input').set('Bottom Le')

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.to_not change { PeopleManager.count }

        expect(page).to have_content 'Verwalter*in ist bereits gesetzt.'
      end

      it 'can not add same managed twice' do
        bottom_member.manageds = [bottom_leader]

        visit edit_group_person_path(group_id: bottom_member.primary_group_id, id: bottom_member)

        expect(page).to have_content 'Verwalter*innen'
        expect(page).not_to have_content 'Du bist nicht berechtigt, die Verwalter*innen dieser Person zu ändern.'
        expect(page).to have_content 'Kinder'
        expect(page).to have_content 'Bottom Leader'

        find('a.add_nested_fields[data-association="people_manageds"]').click

        find('#people_manageds_fields input').set('Bottom Le')

        find('.typeahead.dropdown-menu li').click

        expect do
          all('form button[type="submit"]').last.click
        end.to_not change { PeopleManager.count }

        expect(page).to have_content 'Kind ist bereits gesetzt.'
      end
    end

    context 'as bottom_member' do
      let(:user) { bottom_member }

      it 'does not link to top_leader as manager' do
        bottom_member.managers = [top_leader]

        visit group_person_path(group_id: bottom_member.primary_group_id, id: bottom_member)

        expect(page).to_not have_css('dd a', text: 'Top Leader')
        expect(page).to have_css('dd', text: 'Top Leader')
      end
    end

    context 'as bottom_leader' do
      let(:user) { bottom_leader }

      it 'does not show top_leader as managed option' do
        visit edit_group_person_path(group_id: bottom_member.primary_group_id, id: bottom_member)

        find('a.add_nested_fields[data-association="people_manageds"]').click

        find('#people_manageds_fields input').set('Top Leader')

        expect(page).to_not have_css '.typeahead.dropdown-menu li'
      end
    end
  end

  describe 'people merge' do
    let(:user) { top_leader }
    let(:person_1) { Fabricate('Group::BottomLayer::Member', group: groups(:bottom_layer_one)).person }
    let(:person_2) { Fabricate('Group::BottomLayer::Member', group: groups(:bottom_layer_one)).person }
    let!(:duplicate_entry) { PersonDuplicate.create!(person_1: person_1, person_2: person_2) }

    it 'merges managers' do
      person_1.managers = [top_leader]
      person_1.save
      person_2.managers = [bottom_leader]
      person_2.save

      visit group_person_duplicates_path(groups(:bottom_layer_one))

      find_all('.person-duplicates-table td.vertical-middle a').first.click

      find('form .modal-footer button').click

      expect(page).to have_content('Die Personen Einträge wurden erfolgreich zusammengeführt.')

      expect(PersonDuplicate.where(id: duplicate_entry.id)).to_not exist
      expect(Person.where(id: person_2.id)).to_not exist
      expect(person_1.managers.reload).to match_array([top_leader, bottom_leader])
    end

    it 'merges manageds' do
      person_1.manageds = [top_leader]
      person_1.save
      person_2.manageds = [bottom_leader]
      person_2.save

      visit group_person_duplicates_path(groups(:bottom_layer_one))

      find_all('.person-duplicates-table td.vertical-middle a').first.click

      find('form .modal-footer button').click

      expect(page).to have_content('Die Personen Einträge wurden erfolgreich zusammengeführt.')

      expect(PersonDuplicate.where(id: duplicate_entry.id)).to_not exist
      expect(Person.where(id: person_2.id)).to_not exist
      expect(person_1.manageds.reload).to match_array([top_leader, bottom_leader])
    end

    it 'prioritizes target manageds when merging both managers and manageds' do
      person_1.manageds = [top_leader]
      person_1.save
      person_2.managers = [bottom_leader]
      person_2.save

      visit group_person_duplicates_path(groups(:bottom_layer_one))

      find_all('.person-duplicates-table td.vertical-middle a').first.click

      find('form .modal-footer button').click

      expect(page).to have_content('Die Personen Einträge wurden erfolgreich zusammengeführt.')

      expect(PersonDuplicate.where(id: duplicate_entry.id)).to_not exist
      expect(Person.where(id: person_2.id)).to_not exist
      expect(person_1.manageds.reload).to match_array([top_leader])
    end

    it 'prioritizes target managers when merging both managers and manageds' do
      person_1.managers = [top_leader]
      person_1.save
      person_2.manageds = [bottom_leader]
      person_2.save

      visit group_person_duplicates_path(groups(:bottom_layer_one))

      find_all('.person-duplicates-table td.vertical-middle a').first.click

      find('form .modal-footer button').click

      expect(page).to have_content('Die Personen Einträge wurden erfolgreich zusammengeführt.')

      expect(PersonDuplicate.where(id: duplicate_entry.id)).to_not exist
      expect(Person.where(id: person_2.id)).to_not exist
      expect(person_1.managers.reload).to match_array([top_leader])
    end
  end
end
