class ApplicationController < ActionController::API
  include MonsoonOpenstackAuth::Authentication
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  rescue_from "MonsoonOpenstackAuth::Authentication::NotAuthorized", with: :render_401

  private

  def require_project 
    @project = current_user.project_id
    if @project.nil? || @project.blank?
      render :json  => "{'error':'Project id not found in token.'}".to_json, :status => :forbidden
    end
  end

  def render_404(exception)
    message = if exception.respond_to?(:model)
      "#{exception.model} not found"
    elsif exception.message =~ /Couldn't find ([^ ]+)/
      "#{$1} not found"
    else
      "not found"
    end
    render :json  => {error: message}.to_json, :status => :not_found
  end

  def render_401(exception)
    render :json  => {error: exception.message}.to_json, :status => :unauthorized
  end

end
