# == Schema Information
#
# Table name: automations
#
#  id                  :integer          not null, primary key
#  type                :string           not null
#  name                :string           not null
#  project_id          :string
#  repository          :string
#  repository_revision :string
#  tags                :jsonb
#  timeout             :integer          default(3600), not null
#  run_list            :string           is an Array
#  chef_attributes     :jsonb
#  log_level           :string
#  path                :string
#  arguments           :string           is an Array
#  environment         :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_automations_on_project_id  (project_id)
#

class Automation < ActiveRecord::Base

  validates_presence_of :type, :name, :project_id, :tags
  validates_uniqueness_of :name, scope: :project_id
  validates_length_of :name, minimum: 3, maximum: 256

  # validate project_id really exists??

  def self.all_from_project(project)
    self.where(project_id: project).reorder('updated_at DESC')
  end

  def self.all_from_project!(project)
    automations = self.all_from_project(project)
    raise ActiveRecord::RecordNotFound if automation.nil?
    automations
  end

  def self.find_by_name(name, project)
    self.where(name: name, project_id: project).first
  end

  def self.find_by_name!(name, project)
    automation = self.find_by_name(name, project)
    raise ActiveRecord::RecordNotFound if automation.nil?
    automation
  end

end
