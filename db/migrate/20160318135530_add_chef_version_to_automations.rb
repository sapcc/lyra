class AddChefVersionToAutomations <ActiveRecord::Migration[5.2]
  def change
    add_column :automations, :chef_version, :string
  end
end
