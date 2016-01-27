# == Schema Information
#
# Table name: automations
#
#  id         :integer          not null, primary key
#  type       :string
#  name       :string
#  project_id :string
#  git_url    :string
#  tags       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Chef < Automation

end
