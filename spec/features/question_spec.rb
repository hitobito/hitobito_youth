# frozen_string_literal: true

#  Copyright (c) 2012-2024, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe EventsController, js: true do
  let(:event) do
    Fabricate(:event, groups: [groups(:top_group)]).tap do |event|
      event.dates.create!(start_at: 10.days.ago, finish_at: 5.days.ago)
      event.init_questions
    end
  end
  let(:question_templates) do
    {
      ahv_number: Event::QuestionTemplate.create!(
        group: groups(:top_layer),
        default: true,
        question: Event::Question::AhvNumber.create!(question: "AHV-Number?")
      )
    }
  end

  def click_save
    all("form .btn-group").first.click_button "Speichern"
  end

  def click_next
    all(".bottom .btn-group").first.click_button "Weiter"
  end

  def click_signup
    all(".bottom .btn-group").first.click_button "Anmelden"
  end

  def find_question_field(question)
    page.all(".fields").find { |question_element| question_element.text.start_with?(question.question) }
  end

  describe "global Event::Question::AhvNumber" do
    subject(:question_fields_element) do
      click_link I18n.t("event.participations.application_answers")
      page.find("#application_questions_fields")
    end

    before do
      Event::QuestionTemplate.delete_all
      question_templates
      sign_in
      visit edit_group_event_path(event.group_ids.first, event.id)
    end

    it "includes global questions with matching event type" do
      is_expected.to have_text(question_templates[:ahv_number].question.question)

      is_expected.to have_no_text('Mögliche Antworten')
      is_expected.to have_no_text('Mehrfachauswahl')
      is_expected.to have_no_text('Entfernen')
    end
  end

  describe "answers for global questions" do
    let(:user) { people(:bottom_member) }
    let(:event_with_questions) do
      event.init_questions
      event.application_questions.map { |question| question.update!(required: question.required || false) }
      event.save!
      event
    end

    subject { page }

    before do
      Event::QuestionTemplate.delete_all
      question_templates
      event_with_questions
      sign_in(user)
      visit contact_data_group_event_participations_path(event.group_ids.first, event.id, event_role: {type: Event::Role::Participant})
      click_next
    end

    it "fails with empty required question" do
      sleep 0.5 # avoid wizard race condition

      within find_question_field(question_templates[:ahv_number].question) do
        answer_element = find('input[type="text"]')
        answer_element.fill_in(with: "Not An AHV-Number")
      end
      click_signup
      is_expected.to have_content "Antwort muss im gültigen Format sein (756.1234.5678.97)"

      within find_question_field(question_templates[:ahv_number].question) do
        answer_element = find('input[type="text"]')
        answer_element.fill_in(with: "756.1234.5678.90")
      end
      click_signup
      is_expected.to have_content "Antwort muss eine gültige Prüfziffer haben."

      within find_question_field(question_templates[:ahv_number].question) do
        answer_element = find('input[type="text"]')
        answer_element.fill_in(with: "756.1234.5678.97")
      end
      click_signup
      is_expected.to have_content "Teilnahme von Bottom Member in Eventus wurde erfolgreich erstellt."
    end
  end
end
