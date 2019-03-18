class ApplicationController < ActionController::Base
  include MonsoonOpenstackAuth::Authentication
  include MonsoonOpenstackAuth::Authorization
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from 'MonsoonOpenstackAuth::Authentication::NotAuthorized', with: :render_401
  rescue_from 'MonsoonOpenstackAuth::Authorization::SecurityViolation', with: :render_403

  private

  def require_project
    @project = current_user.project_id
    if @project.nil? || @project.blank?
      render json: "{'error':'Project id not found in token.'}".to_json, status: :forbidden
    end
  end

  def render_404(exception)
    message = if exception.respond_to?(:model)
                "#{exception.model} not found"
              elsif exception.message =~ /Couldn't find ([^ ]+)/
                "#{Regexp.last_match(1)} not found"
              else
                'not found'
    end
    render json: { error: message }.to_json, status: :not_found
  end

  def render_401(exception)
    render json: { error: exception.message }.to_json, status: :unauthorized
  end

  def render_403(exception)
    message = 'You are not authorized.'
    if exception.respond_to?(:involved_roles) && exception.involved_roles && exception.involved_roles.length.positive?
      message += " Please check (role assignments) if you have one of the following roles: #{exception.involved_roles.flatten.join(', ')}."
    end
    render json: { error: message }.to_json, status: :forbidden
  end
end
