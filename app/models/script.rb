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

class Script < Automation

  validates_presence_of :repository, :path
  validates :repository, format: { with: URI.regexp }
  validates :environment, json: true, allow_blank: true

end
