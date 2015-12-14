class ApplicationController < ActionController::API
  include MonsoonOpenstackAuth::Authentication
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  rescue_from "MonsoonOpenstackAuth::Authentication::NotAuthorized", with: :render_401

  def render_404(exception)
    render :nothing  => true, :status => 404
  end

  def render_401(exception)
    render :nothing  => true, :status => 401
  end

end
