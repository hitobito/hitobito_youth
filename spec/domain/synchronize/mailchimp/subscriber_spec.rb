# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Synchronize::Mailchimp::Subscriber do
  let(:person)       { people(:top_leader) }

  context '#mailing_list_subscribers (synchronization strategies)' do
    let(:mailing_list) { Fabricate(:mailing_list, group: groups(:top_layer)) }

    before do
      mailing_list.subscriptions.create!(subscriber: person)
      person.additional_emails <<
        AdditionalEmail.new(label: 'vater', email: 'vater@example.com', mailings: true)
    end

    subject { described_class.mailing_list_subscribers(mailing_list) }

    context 'default strategy' do
      it 'returns all people and their manager' do
        manager = Fabricate(:person)
        person.managers = [manager]

        subscribers = subject
        expect(subscribers.count).to eq(2)

        managed_subscriber = subscribers.first
        manager_subscriber = subscribers.last

        expect(managed_subscriber.email).to eq(person.email)
        expect(managed_subscriber.person).to eq(person)
        expect(manager_subscriber.email).to eq(manager.email)
        expect(manager_subscriber.person).to eq(manager)
      end
    end

    context 'strategy to include additional emails' do
      let(:bottom_member) { people(:bottom_member) }

      before do
        mailing_list.subscriptions.create(subscriber: bottom_member)
        bottom_member.additional_emails.create!({
          label: 'vater bottom',
          email: 'vater+bottom@example.com',
          mailings: true
        })
        mailing_list.mailchimp_include_additional_emails = true
      end

      it 'returns an entry per person and email (default and additional) and their managers' do
        manager = Fabricate(:person)
        person.managers = [manager]

        additional = Fabricate(:additional_email, contactable: manager, mailings: true)

        expect(subject.count).to eq(6)
        expect(subject.map(&:email)).to match_array([
          person.email,
          'vater@example.com',
          bottom_member.email,
          'vater+bottom@example.com',
          manager.email,
          additional.email
        ])
      end
    end
  end
end
