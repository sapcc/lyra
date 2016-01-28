class CreateAutomations < ActiveRecord::Migration
  def change
    create_table :automations do |t|
      # Primary keys - By default, Active Record will use an integer column named id as the table's primary key.
      t.string :type, null: false
      t.string :name, null: false
      t.string :project_id 
      t.string :repository
      t.string :repository_revision
      t.jsonb :tags
      t.integer :timeout, null: false, default: 3600

      #Chef automation
      t.string :run_list, array: true
      t.jsonb  :chef_attributes
      t.string :log_level

      #Script automation
      t.string :path
      t.string :arguments, array: true
      t.jsonb  :environment

      t.timestamps null: false # creates automatically created_at and updated_at
    end
    add_index :automations, [:project_id]
  end
end
