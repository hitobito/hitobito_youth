class AddNationalityForJubla < ActiveRecord::Migration
  def change
    if defined?(HitobitoJubla) && !column_exists?(:people, :nationality)
      add_column :people, :nationality, :string
    end
  end
end
