class ChangeOwnerToJson <ActiveRecord::Migration[5.2]
  def up 
    change_column :runs, :owner, :jsonb, using: %{('{"id":"' || "owner" || '"}')::jsonb}
  end

  def down
    change_column :runs, :owner, :string, using: %{"owner"->>'id'}
  end
end
