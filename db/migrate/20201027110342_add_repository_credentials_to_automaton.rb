# frozen_string_literal: true

class AddRepositoryCredentialsToAutomaton < ActiveRecord::Migration[5.2]
  def up
    add_column :automations, :repository_credentials, :string
  end

  def down
    remove_column :automations, :repository_credentials
  end
end
