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
  include Pagination
  validates_presence_of :type, :name, :project_id
  validates_uniqueness_of :name, scope: :project_id
  validates_length_of :name, minimum: 3, maximum: 256
  validates :tags, json: true, allow_blank: true

  has_many :runs, dependent: :nullify, inverse_of: :automation

  default_scope do
    order("created_at DESC")
  end

  # validate project_id really exists??

  def self.by_project_all(project, page=nil, per_page=nil)
    pag = PaginationInfo.new(self.where(project_id: project).count, page, per_page)
    elements = self.where(project_id: project).page(pag.page).per_page(pag.per_page)
    {elements: elements, pagination: pag}
  end

  def self.by_project_find(project_id, automation_id)
    self.by_project(project_id).find(automation_id)
  end

  def self.by_project(project_id)
    self.where(project_id: project_id)
  end

  # https://github.com/rails/rails/issues/3508#issuecomment-29858772
  def serializable_hash(options=nil)
    super.merge "type" => type
  end

  def create_job(token, selector)
    raise "Not implemented"
  end

end
