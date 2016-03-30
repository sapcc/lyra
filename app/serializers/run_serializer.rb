class RunSerializer < ActiveModel::Serializer
  attributes :id, :log, :created_at, :updated_at, :repository_revision, :state, :log, :jobs, :owner

  def id
    object.id.to_s
  end
end
