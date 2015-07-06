# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

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
