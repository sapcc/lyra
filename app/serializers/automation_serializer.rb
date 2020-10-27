# frozen_string_literal: true

class AutomationSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :project_id, :repository, :repository, :repository_revision, :repository_credentials_enabled, :timeout, :tags, :created_at, :updated_at

  # chef
  attributes :run_list, :chef_attributes, :log_level, :debug, :chef_version

  # script
  attributes :path, :arguments, :environment
end
