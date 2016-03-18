class AddChefVersionToAutomations < ActiveRecord::Migration
  def change
    add_column :automations, :chef_version, :string
  end
end
