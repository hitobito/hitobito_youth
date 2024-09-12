# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe MailRelay::AddressList do

  let(:top_leader)    { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }
  let(:manager)       { people(:people_manager) }
  let(:managed)       { people(:people_managed) }

  context 'entries' do
    it 'contains main and additional managers mailing emails' do
      e1 = Fabricate(:additional_email, contactable: manager, mailings: true)
      e2 = Fabricate(:additional_email, contactable: top_leader, mailings: true)

      Fabricate(:additional_email, contactable: manager, mailings: false)
      Fabricate(:additional_email, contactable: managed, mailings: false)
      expect(entries([managed, top_leader])).to match_array([
        managed.email,
        'top_leader@example.com',
        manager.email,
        e1.email,
        e2.email
      ])
    end

    it 'does not contain blank manager emails' do
      manager.update!(email: ' ')

      expect(entries(managed)).to match_array([
        managed.email
      ])
    end

    it 'it uses only manager additional_email if label matches' do
      e1 = Fabricate(:additional_email, contactable: managed, label: 'foo')
      e2 = Fabricate(:additional_email, contactable: manager, label: 'foo')
      Fabricate(:additional_email, contactable: manager, label: 'bar')
      expect(entries(managed, %w(foo))).to match_array([
        e1.email,
        e2.email
      ])
    end

    it 'it uses manager additional_email and main address if matches' do
      e1 = Fabricate(:additional_email, contactable: managed, label: 'foo')
      e2 = Fabricate(:additional_email, contactable: manager, label: 'foo')
      expect(entries(managed, %W(foo #{MailingList::DEFAULT_LABEL}))).to match_array([
        e1.email,
        e2.email,
        managed.email,
        manager.email
      ])
    end

    it 'for new person returns only the person' do
      new_manager = Fabricate.build(:person)
      new_person = Fabricate.build(:person, managers: [new_manager])
      expect(entries(new_person)).to match_array([
        new_person.email,
        new_manager.email
      ])
    end
  end

  def entries(people = Person.all, labels = [])
    described_class.new(people, labels).entries
  end
end
