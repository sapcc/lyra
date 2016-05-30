require 'active_support/concern'
module MonsoonOpenstackAuthWrapper
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
    before_perform do |job|
      raise "No arguments passed to job" if job.arguments.blank?
      token = if job.arguments.first.kind_of?(Hash)
        job.arguments.first[:token] || job.arguments.first['token']
      else
        job.arguments.first
      end
      raise "token not found in job arguments" if token.blank?
      context = ::MonsoonOpenstackAuth.api_client.validate_token(token)
      @current_user = ::MonsoonOpenstackAuth::Authentication::AuthUser.new(context)
    end
  end

end
