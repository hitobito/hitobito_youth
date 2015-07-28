# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class RenamePeopleNationalityToNationalityJS < ActiveRecord::Migration
  def change
    if defined?(HitobitoJubla) && column_exists?(:people, :nationality)
      add_column :people, :nationality_j_s, :string
    else
      rename_column :people, :nationality, :nationality_j_s
    end

    change_column :people, :nationality_j_s, :string, limit: 5
  end
end
