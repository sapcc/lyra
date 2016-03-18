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
#  chef_version        :string
#
# Indexes
#
#  index_automations_on_project_id  (project_id)
#

class Automation < ActiveRecord::Base

  validates_presence_of :type, :name, :project_id
  validates_uniqueness_of :name, scope: :project_id
  validates_length_of :name, minimum: 3, maximum: 256
  validates :tags, json: true

  has_many :runs

  # validate project_id really exists??

  def self.all_from_project(project)
    self.where(project_id: project).reorder('updated_at DESC')
  end

  def self.all_from_project!(project)
    automations = self.all_from_project(project)
    raise ActiveRecord::RecordNotFound if automations.nil?
    automations
  end

  def self.find_by_id(id, project)
    self.where(id: id, project_id: project).first
  end

  def self.find_by_id!(id, project)
    automation = self.where(id: id, project_id: project).first
    raise ActiveRecord::RecordNotFound if automation.nil?
    automation
  end

  def self.find_by_name(name, project)
    self.where(name: name, project_id: project).first
  end

  def self.find_by_name!(name, project)
    automation = self.find_by_name(name, project)
    raise ActiveRecord::RecordNotFound if automation.nil?
    automation
  end

  # https://github.com/rails/rails/issues/3508#issuecomment-29858772
  def serializable_hash(options=nil)
    super.merge "type" => type
  end

end
