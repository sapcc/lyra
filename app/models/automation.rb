# frozen_string_literal: true
# == Schema Information
#
# Table name: automations
#
#  id                     :integer          not null, primary key
#  type                   :string           not null
#  name                   :string           not null
#  project_id             :string
#  repository             :string
#  repository_revision    :string
#  tags                   :jsonb
#  timeout                :integer          default(3600), not null
#  run_list               :string           is an Array
#  chef_attributes        :jsonb
#  log_level              :string
#  path                   :string
#  arguments              :string           is an Array
#  environment            :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  chef_version           :string
#  debug                  :boolean          default(FALSE)
#  repository_credentials :string
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
  validates :timeout, inclusion: { in: 1..86_400, message: 'must be within 1-86400' }

  has_many :runs, dependent: :nullify, inverse_of: :automation

  default_scope do
    order('created_at DESC')
  end

  # validate project_id really exists??

  def repository_authentication_enabled
    self[:repository_credentials].blank? ? false : true
  end

  def self.by_project_all(project, page = nil, per_page = nil)
    pag = PaginationInfo.new(where(project_id: project).count, page, per_page)
    elements = where(project_id: project).page(pag.page).per_page(pag.per_page)
    { elements: elements, pagination: pag }
  end

  def self.by_project_find(project_id, automation_id)
    by_project(project_id).find(automation_id)
  end

  def self.by_project(project_id)
    where(project_id: project_id)
  end

  # https://github.com/rails/rails/issues/3508#issuecomment-29858772
  def serializable_hash(options = nil)
    super.merge 'type' => type
  end

  def create_job(_token, _selector)
    raise 'Not implemented'
  end
end
