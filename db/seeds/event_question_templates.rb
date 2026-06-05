#  Copyright (c) 2026, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

def available_locales(attrs)
  attrs.select do
    Settings.application.languages.keys.map(&:to_s).include?(_1.to_s.split("_").last)
  end
end

# seed_once defaults to [:id], it runs WHERE id IS NULL and always creates a new record
# We use :type and event_id as the constraint because we want to seed only one global question of that type
question = Event::Question::AhvNumber.seed_once(
  :type, :event_id,
  event_id: nil,
  type: Event::Question::AhvNumber.sti_name,
  **available_locales({
    question_de: "AHV-Nummer?",
    question_fr: "Numéro AVS?",
    question_it: "Numero AVS?"
  })
).first

# We don't want to seed a question template with a question_id that already exists
Event::QuestionTemplate.seed_once(:question_id,
  group_id: Group.root_id,
  question_id: question.id,
  event_type: nil,
  default: true,
  inherit: true
) if question
