# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'


describe GroupAbility do

  subject { ability }
  let(:ability) { Ability.new(role.person.reload) }

  context 'education' do

    def ability(name, role)
      group = groups(name)
      Ability.new(Fabricate("#{group.class.name}::#{role}", group: group).person)
    end

    context :layer_and_below_full do
      it 'may show education in layer group' do
        expect(ability(:top_group, "Leader")).to be_able_to(:education, groups(:top_layer))
      end

      it 'may show education in layer below' do
        expect(ability(:top_group, "Leader")).to be_able_to(:education, groups(:bottom_layer_one))
      end

      it 'may show education in same layer' do
        expect(ability(:bottom_layer_one, "Leader")).to be_able_to(:education, groups(:bottom_layer_one))
      end

      it 'may not show education in group below' do
        expect(ability(:bottom_layer_one, "Leader")).not_to be_able_to(:education, groups(:bottom_group_one_one))
      end

      it 'may not show education in upper layer' do
        expect(ability(:bottom_layer_one, "Leader")).not_to be_able_to(:education, groups(:top_layer))
      end
    end

    context :layer_full do
      it 'may show education in layer group' do
        expect(ability(:top_group, "LocalGuide")).to be_able_to(:education, groups(:top_layer))
      end

      it 'may not show education in layer below' do
        expect(ability(:top_group, "LocalGuide")).not_to be_able_to(:education, groups(:bottom_layer_one))
      end

      it 'may show education in same layer' do
        expect(ability(:bottom_layer_one, "LocalGuide")).to be_able_to(:education, groups(:bottom_layer_one))
      end

      it 'may not show education in group below' do
        expect(ability(:bottom_layer_one, "LocalGuide")).not_to be_able_to(:education, groups(:bottom_group_one_one))
      end

      it 'may not show education in upper layer' do
        expect(ability(:bottom_layer_one, "LocalGuide")).not_to be_able_to(:education, groups(:top_layer))
      end
    end
  end


end
