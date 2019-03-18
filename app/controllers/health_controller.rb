class HealthController < ActionController::Base
  def show
    render plain: 'ok', status: 200, content_type: 'text/plain'
  end
end
