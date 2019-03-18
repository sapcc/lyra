class AddDebugToAutomations <ActiveRecord::Migration[5.2]

  def up
    add_column :automations, :debug, :boolean, default: false
    Automation.all.each do |automation|
      value = false
      unless automation.log_level.blank?
        value = true if automation.log_level.downcase == 'debug'
      end
      automation.update_attributes!(:debug => value)
    end
  end

  def down
    remove_column :automations, :debug
  end

end
