class Api::V1::RunsController < ApplicationController
  api_authentication_required rescope: false # do not rescope after authentication
  before_action :require_project
  
  # GET api/v1/runs.json
  def index
    @runs = Run.by_project_all(@project, params[:page], params[:per_page])
    @runs[:pagination].headers(response)
    render json: @runs[:elements]
  end

  # GET api/v1/runs/1.json
  def show
    run = Run.by_project(@project).find(params[:id])
    render json: run
  end

  # POST api/v1/runs.json
  def create
    automation = Automation.by_project(@project).find(run_params[:automation_id])
    @run = Run.new(run_params.merge!(automation: automation, token: current_user.token, owner: current_user))

    if @run.save
      render json: @run, status: :created
    else
      Rails.logger.error @run.errors.inspect
      render json: {errors: @run.errors}, status: :unprocessable_entity
    end
  end

  private

  def run_params
    params.permit(:automation_id, :selector)
  end
 
end
