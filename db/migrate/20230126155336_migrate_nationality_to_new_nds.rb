# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class MigrateNationalityToNewNds < ActiveRecord::Migration[6.1]
  def up
    change_column :people, :nationality_j_s, :string, limit: nil

    say 'changing people.nationality_j_s DIV -> ANDERE'
    execute <<~SQL
      UPDATE people
      SET nationality_j_s = 'ANDERE'
      WHERE nationality_j_s = 'DIV'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE people
      SET nationality_j_s = 'DIV'
      WHERE nationality_j_s = 'ANDERE'
    SQL

    change_column :people, :nationality_j_s, :string, limit: 5
  end
end
