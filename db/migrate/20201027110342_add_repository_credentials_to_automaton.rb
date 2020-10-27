# frozen_string_literal: true

class AddRepositoryCredentialsToAutomaton < ActiveRecord::Migration[5.2]
  def up
    add_column :automations, :repository_credentials, :string
    add_column :automations, :repository_credentials_enabled, :boolean, default: false
    Automation.all.each do |automation|
      automation.update_attributes!(repository_credentials_enabled: false)
    end
  end

  def down
    remove_column :automations, :repository_credentials
    remove_column :automations, :repository_credentials_enabled
  end
end
