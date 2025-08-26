# frozen_string_literal: true

#  Copyright (c) 2025-2025, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class TransferAhvNumberToEvents < ActiveRecord::Migration[7.1]
  def up
    answers_lookup, ahv_number_transfer = prepare_queries

    say_with_time("Checking need for transfer") do
      if select_values(answers_lookup).blank?
        say "No target questions found that need the AHV-Number, skipping transfer", true
        return
      end
    end

    say_with_time "Transferring AHV-Number to Answers" do
      execute(ahv_number_transfer)
    end

    # remove_column does not known about CASCADE
    execute(<<~SQL.squish)
      ALTER TABLE "people" DROP COLUMN "ahv_number" CASCADE
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Possible to do, but IMHO not worth it"
  end

  private

  def prepare_queries
    today = Time.zone.now.midnight

    ahv_question_lookup = <<~SQL.squish
      SELECT id
      FROM event_questions
      WHERE derived_from_question_id IS NULL
      AND type = 'Event::Question::AhvNumber'
    SQL

    # event_answers.answer,
    # event_answers.question_id,
    # event_questions.disclosure,
    # event_participations.person_id,
    answers_lookup = <<~SQL.squish
      SELECT event_answers.id, people.ahv_number
      FROM event_answers
        INNER JOIN event_questions ON event_answers.question_id = event_questions.id
        INNER JOIN event_participations ON event_answers.participation_id = event_participations.id
        INNER JOIN people ON event_participations.person_id = people.id
        INNER JOIN events ON event_participations.event_id = events.id
        INNER JOIN event_dates ON events.id = event_dates.event_id
      WHERE
        (event_dates.start_at >= '#{today}' OR event_dates.finish_at >= '#{today}')
        AND event_questions.derived_from_question_id = (#{ahv_question_lookup})
        AND event_answers.answer IS NULL
        AND people.ahv_number IS NOT NULL
        AND people.ahv_number != ''
    SQL

    ahv_number_transfer = <<~SQL.squish
      WITH data_query AS (#{answers_lookup})
      UPDATE event_answers
      SET answer = data_query.ahv_number
      FROM data_query
      WHERE event_answers.id = data_query.id
    SQL

    [answers_lookup, ahv_number_transfer]
  end
end
