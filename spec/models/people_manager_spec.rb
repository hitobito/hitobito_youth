# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe PeopleManager do
  let(:top_leader) { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }

  describe 'validations' do
    it 'does not allow manager and managed to be the same' do
      pm = PeopleManager.new(manager: top_leader, managed: top_leader)

      expect(pm).to_not be_valid
    end

    it 'does not allow manager to manage same person multiple times' do
      PeopleManager.create(manager: top_leader, managed: bottom_member)

      pm = PeopleManager.new(manager: top_leader, managed: bottom_member)

      expect(pm).to_not be_valid
    end

    it 'allows person to have multiple managers' do
      PeopleManager.create(manager: top_leader, managed: bottom_member)

      pm = PeopleManager.new(manager: Fabricate(:person), managed: bottom_member)

      expect(pm).to be_valid
    end

    it 'allows person to have multiple manageds' do
      PeopleManager.create(manager: top_leader, managed: bottom_member)

      pm = PeopleManager.new(manager: top_leader, managed: Fabricate(:person))

      expect(pm).to be_valid
    end
  end

end
