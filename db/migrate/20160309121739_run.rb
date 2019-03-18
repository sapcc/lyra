class Run <ActiveRecord::Migration[5.2]
  def change
    create_table :runs do |t|
      t.string  :job_id,         null: false
      t.integer :automation_id
      t.string  :selector 
      t.string  :repository_revision
      t.jsonb   :automation_attributes
      t.string  :state,          null: false, default: 'preparing'
      t.string  :log
      t.string  :jobs,           array: true
      t.string  :owner,          null: false
      t.string  :project_id,     null: false

      t.timestamps null: false # creates automatically created_at and updated_at
    end
    add_index :runs, [:automation_id]
    add_index :runs, [:job_id], unique: true
    add_index :runs, [:project_id]
  end
end
