class AutomationSnapshotSerializer < ActiveModel::Serializer
  attributes :name, :repository, :repository_revision, :timeout, :tags

  #chef
  attributes :run_list, :chef_attributes, :log_level, :chef_version

  #script
  attributes :path, :arguments, :environment

end
