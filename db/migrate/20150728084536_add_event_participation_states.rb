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
    end

    # Recalculate the counts of all events
    Event.find_each { |e| e.refresh_participant_counts! }
  end

  def down
    remove_column(:events, :tentative_applications)
    remove_column(:event_participations, :state)
    remove_column(:event_participations, :canceled_at)
  end
end
