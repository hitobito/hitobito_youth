# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Alpen-Club. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe PeopleManagerAbility do

  let(:top_leader) { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }

  subject(:ability) { Ability.new(person) }

  def build(managed: nil, manager: nil)
    PeopleManager.new(managed: managed, manager: manager)
  end

  [:create_manager, :destroy_manager].each do |action|

    context 'top leader' do
      let(:person) { top_leader }

      describe "#{action} manager" do
        it 'may change manager of bottom_member' do
          expect(ability).to be_able_to(action, build(managed: bottom_member))
        end

        it 'may not change his own manager' do
          expect(ability).not_to be_able_to(action, build(managed: top_leader))
        end

        it 'may change manager of new record' do
          expect(ability).to be_able_to(action, build(managed: Person.new))
        end
      end
    end

    context 'bottom member' do
      let(:person) { bottom_member }

      describe "#{action} manager" do
        it 'may not change manager of top_leader' do
          expect(ability).not_to be_able_to(action, build(managed: top_leader))
        end

        it 'may not change his own manager' do
          expect(ability).not_to be_able_to(action, build(managed: bottom_member))
        end

        it 'may change manager of new record' do
          expect(ability).to be_able_to(action, build(managed: Person.new))
        end

      end
    end
  end
end
