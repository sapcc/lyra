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

class Chef < Automation
  include Defaults
  default :repository_revision, 'master'

  validates_presence_of :repository_revision, :run_list
  validates :repository, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :chef_attributes, json: true

  def create_job(token, selector)
    ChefAutomationJob.perform_later(token, self, selector)
  end
end
