# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Alpen-Club. This file is part of
#  hitobito_sac_cas and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sac_cas

require 'spec_helper'

shared_examples 'people_managers#destroy' do
  controller(described_class) do
    def destroy
      super { |entry| entry.call_on_yielded }
    end
  end

  let(:entry) do
    PeopleManager.create!(
      manager: people(:bottom_leader),
      managed: people(:bottom_member)
    )
  end

  before { sign_in(people(:root)) }

  def params
    attr = described_class.assoc == :people_managers ? :managed_id : :manager_id
    {
      id: entry.id,
      person_id: entry.send(attr)
    }
  end

  context '#destroy' do
    it 'yields' do
      expect_any_instance_of(PeopleManager).to receive(:call_on_yielded)
      delete :destroy, params: params

      expect { entry.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not destroy entry if household#remove raises error' do
      expect_any_instance_of(PeopleManager).to receive(:call_on_yielded).and_raise('baaad stuff')

      expect do
        delete :destroy, params: params
      end.to raise_error('baaad stuff')

      expect { entry.reload }.not_to raise_error
    end
  end
end
