# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Messages::BulkMail::AddressList do

  let(:top_leader) { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }
  let(:root) { people(:root) }

  context 'entries' do
    it 'contains main and additional manager mailing emails' do
      manager = Fabricate(:person)
      bottom_member.managers = [manager]

      e1 = Fabricate(:additional_email, contactable: top_leader, mailings: true)
      e2 = Fabricate(:additional_email, contactable: manager, mailings: true)
      Fabricate(:additional_email, contactable: bottom_member, mailings: false)
      Fabricate(:additional_email, contactable: manager, mailings: false)

      expect(entries([top_leader, bottom_member, root])).to match_array(
        [
          address(bottom_member.id, 'bottom_member@example.com'),
          address(root.id, 'hitobito@puzzle.ch'),
          address(top_leader.id, 'top_leader@example.com'),
          address(top_leader.id, e1.email),
          address(manager.id, manager.email),
          address(manager.id, e2.email)
        ]
      )
    end

    it 'does not contain blank manager emails' do
      manager = Fabricate(:person)
      bottom_member.managers = [manager]
      manager.email = ' '

      expect(entries([root, top_leader])).to match_array(
        [
          address(root.id, 'hitobito@puzzle.ch'),
          address(top_leader.id, 'top_leader@example.com'),
        ]
      )
    end

    it 'it uses only manager additional_email if label matches' do
      manager = Fabricate(:person)
      top_leader.managers = [manager]

      e1 = Fabricate(:additional_email, contactable: top_leader, label: 'foo')
      e2 = Fabricate(:additional_email, contactable: manager, label: 'foo')
      expect(entries([top_leader], %w(foo))).to match_array(
        [
          address(top_leader.id, e1.email),
          address(manager.id, e2.email),
        ]
      )
    end

    it 'it uses manager additional_email and main address if matches' do
      manager = Fabricate(:person)
      top_leader.managers = [manager]

      e1 = Fabricate(:additional_email, contactable: top_leader, label: 'foo')
      e2 = Fabricate(:additional_email, contactable: manager, label: 'foo')
      expect(entries([top_leader], %W(foo #{MailingList::DEFAULT_LABEL}))).to match_array(
        [
          address(top_leader.id, e1.email),
          address(top_leader.id, top_leader.email),
          address(manager.id, manager.email),
          address(manager.id, e2.email),
        ]
      )
    end
  end

  def address(id, email)
    { person_id: id, email: email }
  end

  def entries(people = Person.all, labels = [])
    described_class.new(people, labels).entries
  end
end
