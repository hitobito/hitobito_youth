# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe EventAbility do

  def ability(person)
    Ability.new(person.reload)
  end

  allowed_roles = [
    # abteilung
    [:bottom_layer_one, 'Leader'],
    [:bottom_layer_one, 'LocalGuide'],
    # bund
    [:top_group, 'Leader'],
    [:top_group, 'LocalGuide']
  ]

  allowed_roles.each do |r|

    it "#{r.second} should be allowed to list_tentatives for event in group #{r.first.to_s}" do
      group = groups(r.first)
      role_name = group.class.name + '::' + r.second
      person = Fabricate(role_name, group: group).person
      event = Fabricate(:youth_course, groups: [group], tentative_applications: true)

      expect(ability(person)).to be_able_to(:list_tentatives, event)
    end

    it "#{r.second} should be allowed to index_revoked_participations for event in group #{r.first.to_s}" do
      group = groups(r.first)
      role_name = group.class.name + '::' + r.second
      person = Fabricate(role_name, group: group).person
      event = Fabricate(:youth_course, groups: [group])

      expect(ability(person)).to be_able_to(:index_revoked_participations, event)
    end
  end

  context 'external_applications active' do
    let(:event) { Fabricate(:event, external_applications: true, groups: [groups(:top_group)]) }

    context 'without roles' do
      let(:person) { Fabricate(:person) }

      it 'can show event' do
        expect(ability(person)).to be_able_to(:show, event)
      end
    end

    context 'as top leader' do
      let(:person) { people(:top_leader) }

      it 'can show event' do
        expect(ability(person)).to be_able_to(:show, event)
      end
    end

    context 'as top bottom_member' do
      let(:person) { people(:bottom_member) }

      it 'can show event' do
        expect(ability(person)).to be_able_to(:show, event)
      end
    end
  end

end
