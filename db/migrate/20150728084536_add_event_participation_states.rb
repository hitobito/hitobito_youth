class AddEventParticipationStates < ActiveRecord::Migration[4.2]
  def up
    unless column_exists?(:events, :tentative_applications)
      add_column(:events, :tentative_applications, :boolean, null: false, default: false)
    end

    unless column_exists?(:event_participations, :canceled_at)
      add_column :event_participations, :canceled_at, :date
    end

    unless column_exists?(:event_participations, :state)
      add_column(:event_participations, :state, :string, limit: 60)

      course_participations =
        Event::Participation.joins(:event).
                             where(events: { type: Event::Course.sti_name })
      course_participations.where(active: true).update_all(state: :assigned)
      course_participations.where(active: false).update_all(state: :applied)
    end

    Event::Participation.reset_column_information
    Event.reset_column_information # to make new column appear

    # Recalculate the counts of all events
    Event.find_each { |e| e.refresh_participant_counts! }
  end

  def down
    remove_column(:events, :tentative_applications)
    remove_column(:event_participations, :state)
    remove_column(:event_participations, :canceled_at)
  end
end
