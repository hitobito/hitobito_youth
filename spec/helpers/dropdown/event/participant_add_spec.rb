require "spec_helper"

describe Dropdown::Event::ParticipantAdd do
  include Rails.application.routes.url_helpers
  include FormatHelper
  include LayoutHelper
  include UtilityHelper

  let(:current_user) { people(:top_leader) }
  let(:event) { events(:top_event) }
  let(:group) { groups(:top_group) }
  let(:dropdown) do
    described_class.for_user(self, group, event, current_user)
  end

  subject { Capybara.string(dropdown.to_s) }

  def menu = subject.find(".btn-group > ul.dropdown-menu")

  it "renders button" do
    is_expected.to have_content "Anmelden"
    is_expected.to_not have_css("ul.dropdown-menu li")
  end

  it "renders for regular event participant" do
    Event::Participation.create!(event: event, participant: current_user)
    is_expected.to have_content "Angemeldet"
    is_expected.to_not have_css("ul.dropdown-menu li")
  end

  context "course" do
    let(:event) { events(:top_course) }

    it "renders dropdown for assigned participant" do
      is_expected.to have_content "Anmelden"
      is_expected.to have_css("ul.dropdown-menu li", count: 2)
      is_expected.to have_css("ul.dropdown-menu li", text: "Top Leader (ist bereits angemeldet)")
      is_expected.not_to have_link("Top Leader (ist bereits angemeldet)")
      is_expected.to have_link("Neues Kind erfassen und anmelden")
    end

    it "renders dropdown for canceled participant" do
      event_participations(:top_leader).update!(state: "canceled", canceled_at: 1.week.ago)

      is_expected.to have_css("ul.dropdown-menu li", count: 2)
      is_expected.to have_css("ul.dropdown-menu li", text: "Top Leader (ist bereits angemeldet)")
      is_expected.not_to have_link("Top Leader (ist bereits angemeldet)")
      is_expected.to have_link("Neues Kind erfassen und anmelden")
    end

    it "renders dropdown for tentative participant" do
      event_participations(:top_leader).update!(state: "tentative")

      is_expected.to have_css("ul.dropdown-menu li", count: 2)
      is_expected.to have_css("ul.dropdown-menu li", text: "Top Leader (ist bereits angemeldet)")
      is_expected.not_to have_link("Top Leader (ist bereits angemeldet)")
      is_expected.to have_link("Neues Kind erfassen und anmelden")
    end

    context "without people managers self_service_managed_creation feature" do
      before do
        allow(FeatureGate).to receive(:enabled?).and_call_original
        allow(FeatureGate).to receive(:enabled?).with("people.people_managers.self_service_managed_creation").and_return(false)
      end

      it "renders disabled for assigned participant" do
        is_expected.to have_content "Angemeldet"
        is_expected.to have_css("a.btn.disabled")
      end

      it "renders disabled for canceled participant" do
        event_participations(:top_leader).update!(state: "canceled", canceled_at: 1.week.ago)
        is_expected.to have_content "Abgemeldet"
        is_expected.to have_css("a.btn.disabled")
      end

      it "renders button for tentative participant" do
        event_participations(:top_leader).update!(state: "tentative")
        is_expected.to have_content "Anmelden"
        is_expected.to have_css("a.btn:not(.disabled)")
        is_expected.not_to have_css("ul.dropdown-menu")
      end

      context "with manageds" do
        let(:child) { Fabricate(:person) }
        before { current_user.manageds = [child] }

        it "renders dropdown for assigned participant" do
          is_expected.to have_css("ul.dropdown-menu li", count: 2)
          is_expected.to have_css("ul.dropdown-menu li", text: "Top Leader (ist bereits angemeldet)")
          is_expected.not_to have_link("Top Leader (ist bereits angemeldet)")
          is_expected.to have_link(child.full_name)
        end

        it "renders dropdown for canceled participant" do
          event_participations(:top_leader).update!(state: "canceled", canceled_at: 1.week.ago)

          is_expected.to have_css("ul.dropdown-menu li", count: 2)
          is_expected.to have_css("ul.dropdown-menu li", text: "Top Leader (ist bereits angemeldet)")
          is_expected.not_to have_link("Top Leader (ist bereits angemeldet)")
          is_expected.to have_link(child.full_name)
        end

        it "renders dropdown for tentative participant" do
          event_participations(:top_leader).update!(state: "tentative")

          is_expected.to have_css("ul.dropdown-menu li", count: 2)
          is_expected.to have_css("ul.dropdown-menu li", text: "Top Leader (ist bereits angemeldet)")
          is_expected.not_to have_link("Top Leader (ist bereits angemeldet)")
          is_expected.to have_link(child.full_name)
        end
      end
    end
  end
end
