class Automation < ActiveRecord::Base

  validates_presence_of :type, :name, :project_id

  # validate name duplicates
  # validate project_id really exists
  # validata name length

  def self.find_by_name(name, project)
    self.where(name: name, project_id: project).first
  end

  def self.find_by_name!(name, project)
    automation = self.find_by_name(name, project)
    raise ActiveRecord::RecordNotFound if automation.nil?
    automation
  end

end
