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

  context 'entries' do
    it 'contains main and additional managers mailing emails' do
      manager = Fabricate(:person)
      bottom_member.managers = [manager]

      e1 = Fabricate(:additional_email, contactable: manager, mailings: true)
      e2 = Fabricate(:additional_email, contactable: top_leader, mailings: true)

      Fabricate(:additional_email, contactable: manager, mailings: false)
      Fabricate(:additional_email, contactable: bottom_member, mailings: false)
      expect(entries([bottom_member, top_leader])).to match_array([
        'bottom_member@example.com',
        'top_leader@example.com',
        manager.email,
        e1.email,
        e2.email
      ])
    end

    it 'does not contain blank manager emails' do
      manager = Fabricate(:person)
      bottom_member.managers = [manager]
      manager.email = ' '

      expect(entries([top_leader])).to match_array([
        'top_leader@example.com'
      ])
    end

    it 'it uses only manager additional_email if label matches' do
      manager = Fabricate(:person)
      top_leader.managers = [manager]

      e1 = Fabricate(:additional_email, contactable: top_leader, label: 'foo')
      e2 = Fabricate(:additional_email, contactable: manager, label: 'foo')
      Fabricate(:additional_email, contactable: manager, label: 'bar')
      expect(entries([top_leader], %w(foo))).to match_array([
        e1.email,
        e2.email
      ])
    end

    it 'it uses manager additional_email and main address if matches' do
      manager = Fabricate(:person)
      top_leader.managers = [manager]

      e1 = Fabricate(:additional_email, contactable: top_leader, label: 'foo')
      e2 = Fabricate(:additional_email, contactable: manager, label: 'foo')
      expect(entries([top_leader], %W(foo #{MailingList::DEFAULT_LABEL}))).to match_array([
        e1.email,
        e2.email,
        top_leader.email,
        manager.email
      ])
    end
  end

  def entries(people = Person.all, labels = [])
    described_class.new(people, labels).entries
  end
end
