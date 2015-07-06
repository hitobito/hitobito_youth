class AddFiverColumnsToEventKinds < ActiveRecord::Migration
  def up
    if column_exists?(:event_kinds, :bsv_id)
      rename_column :event_kinds, :bsv_id, :kurs_id_fiver
    else
      add_column :event_kinds, :kurs_id_fiver, :string
    end
  end

  add_column :event_kinds, :vereinbarungs_id_fiver, :string

  def down
    remove_column :event_kinds, :kurs_id_fiver
    remove_column :event_kinds, :vereinbarungs_id_fiver
  end
end
