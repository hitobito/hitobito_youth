# encoding: utf-8

#  Copyright (c) 2012-2024, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

Event::Question.create_with_translations([
  {
    disclosure: nil, # Has to be chosen for every event
    event_type: nil, # Is derived for every event
    type: Event::Question::AhvNumber.sti_name,
    translation_attributes: [
      { locale: 'de', question: 'AHV-Nummer?' },
      { locale: 'fr', question: 'Numéro AVS ?' },
      { locale: 'it', question: 'Numero AVS?' },
      { locale: 'en', question: 'AVS number?' }
    ]
  },
])
