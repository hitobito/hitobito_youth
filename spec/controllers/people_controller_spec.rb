# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe PeopleController do
  let(:top_leader) { people(:top_leader) }
  let(:bottom_leader) { people(:bottom_leader) }
  let(:bottom_member) { people(:bottom_member) }

  before { sign_in(user) }

  context 'PUT update' do
    context 'self' do
      let(:user) { bottom_leader }
      subject { bottom_leader }

      it 'updates person' do
        expect do
          put :update, params: { id: subject.id,
                                 group_id: subject.primary_group_id,
                                 person: { first_name: 'New' } }
        end.to change { subject.reload.first_name }.to('New')
      end

      it 'does not set managers' do
        manager_attrs = {
          people_managers_attributes: {
            '0' => {
              manager_id: top_leader.id
            }
          }
        }

        expect do
          put :update, params: { id: subject.id,
                                 group_id: subject.primary_group_id,
                                 person: manager_attrs }
        end.to_not change { PeopleManager.count }
      end

      it 'sets manageds' do
        managed_attrs = {
          people_manageds_attributes: {
            '0' => {
              managed_id: bottom_member.id
            }
          }
        }

        expect do
          put :update, params: { id: subject.id,
                                 group_id: subject.primary_group_id,
                                 person: managed_attrs }
        end.to change { PeopleManager.count }.by(1)

        pm = PeopleManager.find_by(manager: subject, managed: bottom_member)

        expect(pm).to be_present
      end

      context 'trying to create new person' do
        context 'with feature gate disabled' do
          before do
            allow(FeatureGate).to receive(:enabled?).and_return(true)
            allow(FeatureGate).to receive(:enabled?).with('people.people_managers.self_service_managed_creation').and_return(false)
          end

          it 'does not work' do
            managed_attrs = {
              people_manageds_attributes: {
                '99' => {
                  managed_id: nil,
                  managed_attributes: {
                    first_name: 'Bob',
                    last_name: 'Miller',
                    birthday: '19.12.2002',
                    gender: 'w'
                  }
                }
              }
            }

            expect do
              put :update, params: { id: subject.id,
                                     group_id: subject.primary_group_id,
                                     person: managed_attrs }
            end.to_not change { Person.count }

            expect(Person.exists?(first_name: 'Bob', last_name: 'Miller')).to eq(false)
          end
        end

        context 'with feature gate enabled' do
          before do
            allow(FeatureGate).to receive(:enabled?).and_return(true)
            allow(FeatureGate).to receive(:enabled?).with('people.people_managers.self_service_managed_creation').and_return(true)
          end

          it 'works' do
            managed_attrs = {
              people_manageds_attributes: {
                '99' => {
                  managed_id: nil,
                  managed_attributes: {
                    first_name: 'Bob',
                    last_name: 'Miller',
                    birthday: '19.12.2002',
                    gender: 'w'
                  }
                }
              }
            }

            expect do
              put :update, params: { id: subject.id,
                                     group_id: subject.primary_group_id,
                                     person: managed_attrs }
            end.to change { Person.count }.by(1)
               .and change { PeopleManager.count }.by(1)

            managed = Person.find_by(first_name: 'Bob', last_name: 'Miller')
            
            pm = PeopleManager.find_by(manager: subject, managed: managed)

            expect(pm).to be_present
          end
        end
      end
    end

    context 'as top_leader', versioning: true do
      let(:user) { top_leader }
      subject { bottom_member }

      it 'updates person' do
        expect do
          put :update, params: { id: subject.id,
                                 group_id: subject.primary_group_id,
                                 person: { first_name: 'New' } }
        end.to change { subject.reload.first_name }.to('New')
      end

      it 'sets managers' do
        manager_attrs = {
          people_managers_attributes: {
            '0' => {
              manager_id: top_leader.id
            }
          }
        }

        expect do
          put :update, params: { id: subject.id,
                                 group_id: subject.primary_group_id,
                                 person: manager_attrs }
        end.to change { PeopleManager.count }.by(1)

        pm = PeopleManager.find_by(managed: subject, manager: top_leader)

        expect(pm).to be_present
      end

      it 'creates paper_trail versions for creating manager' do
        manager_attrs = {
          people_managers_attributes: {
            '0' => {
              manager_id: top_leader.id
            }
          }
        }

        expect do
          put :update, params: { id: subject.id,
                                 group_id: subject.primary_group_id,
                                 person: manager_attrs }
        end.to change { PeopleManager.count }.by(1)
           .and change { PaperTrail::Version.count }.by(3)

        pm = PeopleManager.find_by(managed: subject, manager: top_leader)

        manager_version = PaperTrail::Version.find_by(main_id: top_leader.id, item: pm, event: 'create')
        managed_version = PaperTrail::Version.find_by(main_id: subject.id, item: pm, event: 'create')

        expect(manager_version).to be_present
        expect(managed_version).to be_present
      end

      it 'creates paper_trail versions for removing manager' do
        pm = PeopleManager.create(manager: top_leader, managed: subject)

        manager_attrs = {
          people_managers_attributes: {
            '0' => {
              id: pm.id,
              manager_id: top_leader.id,
              '_destroy': true
            }
          }
        }

        expect do
          put :update, params: { id: subject.id,
                                 group_id: subject.primary_group_id,
                                 person: manager_attrs }
        end.to change { PeopleManager.count }.by(-1)
           .and change { PaperTrail::Version.count }.by(3)

        manager_version = PaperTrail::Version.find_by(main_id: top_leader.id, event: 'destroy')
        managed_version = PaperTrail::Version.find_by(main_id: subject.id, event: 'destroy')

        expect(manager_version).to be_present
        expect(managed_version).to be_present
      end
    end

    context 'as bottom_leader' do
      let(:user) { bottom_leader }

      it 'does not establish managed relation to people without update permission' do
        managed_attrs = {
          people_manageds_attributes: {
            '0' => {
              managed_id: top_leader.id
            }
          }
        }

        expect do
          put :update, params: { id: bottom_member.id,
                                 group_id: bottom_member.primary_group_id,
                                 person: managed_attrs }
        end.to_not change { PeopleManager.count }

        expect(PeopleManager.where(manager: subject, managed: top_leader)).to_not exist
      end
    end
  end
end
