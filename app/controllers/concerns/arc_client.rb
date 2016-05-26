require 'ruby-arc-client'
module ArcClient
  extend ActiveSupport::Concern

  def arc
    @arc ||= RubyArcClient::Client.new(current_user.service_url(:arc))
  end
end
