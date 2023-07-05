# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class AddCourseRelatedFields < ActiveRecord::Migration[4.2]
  def up
    add_if_missing(:events, :training_days, :decimal, precision: 12, scale: 1)

    add_if_missing(:event_kinds, :bsv_id, :string)

    add_if_missing(:people, :nationality, :string)
    add_if_missing(:people, :ahv_number, :string)
    add_if_missing(:people, :j_s_number, :string) # integer in cevi
  end

  def down
    remove_if_present(:events, :training_days)

    remove_if_present(:event_kinds, :bsv_id)

    remove_if_present(:people, :nationality)
    remove_if_present(:people, :ahv_number)
    remove_if_present(:people, :j_s_number)
  end

  private

  def add_if_missing(table, column, type, args = {})
    if !column_exists?(table, column)
      add_column(table, column, type, **args)
    end
  end

  def remove_if_present(table, column)
    if column_exists?(table, column)
      remove_column(table, column)
    end
  end
end
