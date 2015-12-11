class Automation < ActiveRecord::Base

  validates_presence_of :type, :name, :project_id, :tags
  validates_uniqueness_of :name, scope: :project_id
  validates_length_of :name, :maximum=>256

  # validate project_id really exists??

  def self.find_by_name(name, project)
    self.where(name: name, project_id: project).first
  end

  def self.find_by_name!(name, project)
    automation = self.find_by_name(name, project)
    raise ActiveRecord::RecordNotFound if automation.nil?
    automation
  end

end
