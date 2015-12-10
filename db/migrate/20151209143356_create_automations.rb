class CreateAutomations < ActiveRecord::Migration
  def change
    create_table :automations do |t|
      # Primary keys - By default, Active Record will use an integer column named id as the table's primary key.
      t.string :type
      t.string :name
      t.string :project_id
      t.string :git_url
      t.json :tags

      t.timestamps null: false # creates automatically created_at and updated_at

    # add Index???
    end
  end
end
