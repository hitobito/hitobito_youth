#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require "spec_helper"

describe Event::ParticipationsController do
  let(:group) { course.groups.first }
  let(:course) { Fabricate(:youth_course, groups: [groups(:top_layer)]) }
  let(:participation) { assigns(:participation).reload }

  context "without current user" do
    let(:user) { people(:bottom_member) }

    it "GET#new redirects to login page" do
      get :new, params: {group_id: group.id, event_id: course.id, event_participation: {person_id: user.id}}
      expect(response).to redirect_to(new_person_session_path)
    end
  end

  context "with current user" do
    before { sign_in(people(:top_leader)) }

    context "GET#index" do
      it "does not include tentative participants" do
        Fabricate(:event_participation,
          event: course,
          state: "applied",
          person: people(:bottom_member),
          active: true)
        get :index, params: {group_id: group.id, event_id: course.id}
        expect(assigns(:participations)).to be_empty
      end

      it "exports csv files" do
        expect do
          get :index, params: {group_id: group, event_id: course.id}, format: :csv
          expect(flash[:notice]).to match(/Export wird im Hintergrund gestartet und nach Fertigstellung heruntergeladen./)
        end.to change(Delayed::Job, :count).by(1)
      end
    end

    context "POST#create" do
      let(:pending_dj_handlers) { Delayed::Job.all.pluck(:handler) }
      let(:user) { people(:bottom_member) }

      context "confirmation mails" do
        context "as manager" do
          before do
            PeopleManager.create!(manager_id: people(:top_leader).id, managed_id: user.id)
            course.update!(waiting_list: false, maximum_participants: 2, participant_count: 1, automatic_assignment: true)
          end

          it "sends confirmation mail when registering child" do
            expect do
              post :create, params: {group_id: group.id, event_id: course.id, event_participation: {person_id: user.id}}
              expect(assigns(:participation)).to be_valid
            end.to change { Delayed::Job.count }

            expect(pending_dj_handlers).to be_one { |h| h =~ /Event::ParticipationNotificationJob/ }
            expect(pending_dj_handlers).to be_one { |h| h =~ /Event::ParticipationConfirmationJob/ }

            expect(flash[:notice])
              .to include "Teilnahme von <i>#{user}</i> in <i>Eventus</i> wurde erfolgreich erstellt. Bitte überprüfe die Kontaktdaten und passe diese gegebenenfalls an."
            expect(flash[:warning]).to be_nil
          end
        end

        context "as child" do
          before do
            sign_in(user)
            Fabricate(:role, type: Group::TopGroup::Leader.sti_name, person: user, group: groups(:top_group))
            PeopleManager.create!(manager_id: people(:top_leader).id, managed_id: user.id)
            course.update!(waiting_list: false, maximum_participants: 2, participant_count: 1, automatic_assignment: true)
          end

          it "sends confirmation mail to manager when child does not have email" do
            user.update!(email: nil)

            expect do
              post :create, params: {group_id: group.id, event_id: course.id, event_participation: {person_id: user.id}}
              expect(assigns(:participation)).to be_valid
            end.to change { Delayed::Job.count }

            expect(pending_dj_handlers).to be_one { |h| h =~ /Event::ParticipationNotificationJob/ }
            expect(pending_dj_handlers).to be_one { |h| h =~ /Event::ParticipationConfirmationJob/ }

            expect(flash[:notice])
              .to include "Teilnahme von <i>#{user}</i> in <i>Eventus</i> wurde erfolgreich erstellt. Bitte überprüfe die Kontaktdaten und passe diese gegebenenfalls an."
            expect(flash[:warning]).to be_nil
          end
        end
      end

      it "sets participation state to applied" do
        post :create,
          params: {
            group_id: group.id,
            event_id: course.id,
            event_participation: {person_id: people(:top_leader).id}
          }
        expect(participation.state).to eq "applied"

        expect(course.reload.applicant_count).to eq 1
        expect(course.teamer_count).to eq 0
        expect(course.participant_count).to eq 0
      end

      it "sets participation state to assigned when created by organisator" do
        post :create,
          params: {
            group_id: group.id,
            event_id: course.id,
            event_participation: {person_id: people(:bottom_member).id}
          }
        expect(participation.state).to eq "assigned"

        expect(course.reload.applicant_count).to eq 1
        expect(course.teamer_count).to eq 0
        expect(course.participant_count).to eq 1
      end
    end

    context "state changes" do
      let(:participation) { Fabricate(:youth_participation, event: course) }

      context "PUT cancel" do
        it "cancels participation" do
          put :cancel,
            params: {
              group_id: group.id,
              event_id: course.id,
              id: participation.id,
              event_participation: {canceled_at: Date.today}
            }
          expect(flash[:notice]).to be_present
          participation.reload
          expect(participation.canceled_at).to eq Date.today
          expect(participation.state).to eq "canceled"
          expect(participation.active).to eq false

          expect(course.reload.applicant_count).to eq 0
          expect(course.teamer_count).to eq 0
          expect(course.participant_count).to eq 0
        end

        it "refreshes participation count" do
          Event::Course::Role::Participant.create!(participation: participation)
          participation.update!(state: :assigned)
          course.refresh_participant_counts!
          expect do
            put :cancel,
              params: {
                group_id: group.id,
                event_id: course.id,
                id: participation.id,
                event_participation: {canceled_at: Date.today}
              }
          end.to change { course.reload.participant_count }.by(-1)
        end

        it "requires canceled_at date" do
          put :cancel,
            params: {
              group_id: group.id,
              event_id: course.id,
              id: participation.id,
              event_participation: {canceled_at: " "}
            }
          expect(flash[:alert]).to be_present
          participation.reload
          expect(participation.canceled_at).to eq nil
        end
      end

      context "PUT reject" do
        it "rejects participation" do
          put :reject,
            params: {
              group_id: group.id,
              event_id: course.id,
              id: participation.id
            }
          participation.reload
          expect(participation.state).to eq "rejected"
          expect(participation.active).to eq false
        end
      end

      it "PUT attend sets participation state to attended" do
        put :attend,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id
          }
        participation.reload
        expect(participation.active).to be true
        expect(participation.state).to eq "attended"
      end

      it "PUT absent sets participation state to abset" do
        put :absent,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id
          }
        participation.reload
        expect(participation.active).to be false
        expect(participation.state).to eq "absent"
      end

      it "PUT assign sets participation state to abset" do
        put :assign,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id
          }
        participation.reload
        expect(participation.active).to be true
        expect(participation.state).to eq "assigned"
      end
    end

    context "DELETE destroy" do
      context "for managed participation" do
        let(:managed) { Fabricate(:person) }
        let!(:manager_relation) { PeopleManager.create(manager: people(:top_leader), managed: managed) }

        let(:participation) do
          Fabricate(:event_participation,
            event: course,
            state: "applied",
            person: managed,
            active: true)
        end

        it "rediects to event#show" do
          delete :destroy, params: {group_id: group.id,
                                    event_id: course.id,
                                    id: participation.id}

          expect(response).to have_http_status(303)
          expect(response).to redirect_to(group_event_path(group, course))
        end
      end
    end
  end
end
