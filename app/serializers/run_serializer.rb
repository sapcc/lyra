# Serializer for the run model
class RunSerializer < ActiveModel::Serializer
  attributes :id, :log, :created_at, :updated_at, :repository_revision,
             :state, :log, :jobs, :owner, :automation_id, :automation_name,
             :selector, :automation_attributes

  def id
    object.id.to_s
  end

  def automation_name
    object.automation.try(:name)
  end

  def automation_id
    object.automation_id.to_s
  end
end
