# == Schema Information
#
# Table name: runs
#
#  id                    :integer          not null, primary key
#  job_id                :string           not null
#  automation_id         :integer
#  selector              :string
#  repository_revision   :string
#  automation_attributes :jsonb
#  state                 :string           default("preparing"), not null
#  log                   :string
#  jobs                  :string           is an Array
#  owner                 :jsonb            not null
#  project_id            :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_runs_on_automation_id  (automation_id)
#  index_runs_on_job_id         (job_id) UNIQUE
#  index_runs_on_project_id     (project_id)
#

class Run < ActiveRecord::Base
  include Pagination

  attr_accessor :token

  belongs_to :automation, inverse_of: :runs 

  default_scope do
    order("created_at DESC")
  end

  VALID_STATES = %w(preparing executing failed completed)

  before_validation :serialize_owner
  validates :state, inclusion: {in: VALID_STATES, message: "'%{value}' is an invalid state"}

  validates_presence_of :owner, :automation
  validates_presence_of :token, on: :create, if: Proc.new { job_id.blank? }
  validates_associated :automation

  before_save :update_project_id
  before_create :create_job, if: Proc.new { job_id.blank? }

  def self.by_project_all(project_id, page=nil, per_page=nil)
    pag = PaginationInfo.new(self.where("project_id = ?", project_id).count, page, per_page)
    elements = self.where("project_id = ?", project_id).page(pag.page).per_page(pag.per_page)
    {elements: elements, pagination: pag}
  end

  def self.by_project_find(project_id, run_id)
    self.by_project(project_id).find(run_id)
  end

  def self.by_project(project_id)
    self.where("project_id = ?", project_id)
  end

  APPEND_LOG_SQL = <<-SQL.squish
    UPDATE runs SET
      updated_at = now(),
      log = coalesce(log, '') || %s
      WHERE id = %s
  SQL

  def log *args
    if args.length > 0
      log_line = args.first.end_with?("\n") ? args.first : args.first + "\n"
      Run.connection.execute format(APPEND_LOG_SQL, Run.sanitize(log_line), Run.sanitize(id))
    else
      read_attribute :log
    end
  end

  private

  def create_job
    job = automation.create_job(token, selector) 
    self.job_id = job.job_id 
  end

  def update_project_id
    self.project_id = automation.project_id
  end

  def serialize_owner
    if owner.respond_to?(:id)
      self.owner = {
        id: owner.id,
        name: owner.name,
        domain_id: owner.user_domain_id,
        domain_name: owner.user_domain_name
      }
    end
  end

end
