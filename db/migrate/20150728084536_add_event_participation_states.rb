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

      connection = ActiveRecord::Base.connection
      set_assigned = <<-SQL
      UPDATE events 
      SET state = 'assigned' 
      WHERE id IN 
        (
        SELECT events.id FROM event_participations AS participations
        JOIN events ON participations.event_id = events.id
        WHERE events.type = 'Event::Course' AND participations.active = true
        )
      SQL

      set_applied = <<-SQL
      UPDATE events 
      SET state = 'applied' 
      WHERE id IN 
        (
        SELECT events.id FROM event_participations AS participations
        JOIN events ON participations.event_id = events.id
        WHERE events.type = 'Event::Course' AND participations.active = false
        )
      SQL

      connection.execute(set_assigned)
      connection.execute(set_applied)
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
