class Api::V1::AutomationsController < ApplicationController
  api_authentication_required rescope: false # do not rescope after authentication
  before_action :set_project
  before_action :set_automation, only: [:show, :edit, :update, :destroy]

  # GET api/v1/automations.json
  def index
    @automations = Automation.all_from_project(@project)
  end

  # GET /automations/1.json
  def show
  end

  # POST api/v1/automations.json
  def create
    @automation = Automation.new(automation_params.merge!(project_id: @project))

    if @automation.save
      render :show, status: :created
    else
      render json: @automation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT api/v1/automations/1.json
  def update
    if @automation.update(automation_params)
      render :show, status: :ok, location: @automation
    else
      render json: @automation.errors, status: :unprocessable_entity
    end
  end

  # DELETE api/v1/automations/1.json
  def destroy
    @automation.destroy
    head :no_content
  end

  private

    def set_automation
      name = params[:id]
      @automation = Automation.find_by_name!(name, @project)
    end

    def automation_params
      params.require(:automation).permit(:type, :name, :git_url, :tags)
    end

    def set_project
      @project = current_user.project_id
      if @project.nil? || @project.blank?
        render :json  => "{'error':'Project id not found in token.'}".to_json, :status => :forbidden
      end
    end

end