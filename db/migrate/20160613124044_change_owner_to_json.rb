class ChangeOwnerToJson < ActiveRecord::Migration
  def up 
    change_column :runs, :owner, :jsonb, using: %{('{"id":"' || "owner" || '"}')::jsonb}
  end

  def down
    change_column :runs, :owner, :string, using: %{"owner"->>'id'}
  end
end
