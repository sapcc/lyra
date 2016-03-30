class AutomationSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :project_id, :repository, :repository, :repository_revision, :timeout, :tags, :created_at, :updated_at

  #chef
  attributes :run_list, :chef_attributes, :log_level, :chef_version

  #script
  attributes :path, :arguments, :environment

end
