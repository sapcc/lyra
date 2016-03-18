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
#  owner                 :string           not null
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
  belongs_to :automation

  APPEND_LOG_SQL = <<-SQL.squish
    UPDATE runs SET
      updated_at = now(),
      log = coalesce(log, '') || %s
      WHERE id = %s
  SQL

  def log *args
    if args.length > 0
      Run.connection.execute format(APPEND_LOG_SQL, Run.sanitize(args.first), Run.sanitize(id))
    else
      read_attribute :log
    end
  end
end
