class Api::V1::AutomationsController < ApplicationController
  api_authentication_required rescope: false # do not rescope after authentication

  before_action :set_automation, only: [:show, :edit, :update, :destroy]

  # GET api/v1/automations.json
  def index
    @automations = Automation.all
  end

  # GET /automations/1.json
  def show
  end

  # POST api/v1/automations.json
  def create
    @automation = Automation.new(automation_params)

    if @automation.save
      format.json { render :show, status: :created, location: @automation }
    else
      format.json { render json: @automation.errors, status: :unprocessable_entity }
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
      @automation = Automation.find(params[:id])
    end

    def automation_params
      params.require(:automation).permit(:type, :name, :project_id, :git_url, :tags)
    end

end
