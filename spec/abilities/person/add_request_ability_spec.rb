# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and
#  licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Person::AddRequestAbility do
  let(:ability) { Ability.new(role.person.reload) }
  let(:bottom_layer) { groups(:bottom_layer_one) }

  subject { ability }

  context 'as manager' do
    let(:role) { Fabricate(Group::BottomLayer::BasicPermissionsOnly.sti_name.to_sym, group: bottom_layer) }

    it 'is allowed for managed person' do
      other = Fabricate(Group::BottomLayer::Member.sti_name.to_sym, group: bottom_layer).person
      other.managers = [role.person]

      request = create_request(other)

      is_expected.to be_able_to(:approve, request)
      is_expected.to be_able_to(:reject, request)
      is_expected.to be_able_to(:add_without_request, request)
    end

    it 'is not allowed for not managed person' do
      other = Fabricate(Group::BottomLayer::Member.sti_name.to_sym, group: bottom_layer).person
      request = create_request(other)

      is_expected.to_not be_able_to(:approve, request)
      is_expected.to_not be_able_to(:reject, request)
      is_expected.to_not be_able_to(:add_without_request, request)
    end

    it 'is allowed to reject if created by managed person' do
      other = Fabricate(Group::BottomLayer::Member.sti_name.to_sym, group: bottom_layer).person
      requester = Fabricate(Group::BottomLayer::Leader.sti_name.to_sym, group: bottom_layer).person
      requester.managers = [role.person]
      request = create_request(other, requester: requester)

      is_expected.to be_able_to(:reject, request)
    end
  end

  def create_request(person, requester: people(:bottom_leader))
    Person::AddRequest::Group.create!(
      person: person,
      requester: requester,
      body: bottom_layer,
      role_type: Group::BottomLayer::Leader.sti_name
    )
  end
end
