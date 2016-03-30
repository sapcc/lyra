class Api::V1::AutomationsController < ApplicationController
  api_authentication_required rescope: false # do not rescope after authentication
  before_action :require_project
  before_action :set_automation, only: [:show, :edit, :update, :destroy]

  # GET api/v1/automations.json
  def index
    @automations = Automation.by_project(@project)
    render json: @automations
  end

  # GET /automations/1.json
  def show
    render json: @automation
  end

  # POST api/v1/automations.json
  def create
    @automation = Automation.new(automation_params.merge!(project_id: @project))

    if @automation.save
      render json: @automation, status: :created
    else
      Rails.logger.error @automation.errors.inspect
      render json: {errors: @automation.errors}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT api/v1/automations/1.json
  def update
    if @automation.update(automation_params)
      render json: @automation, status: :ok
    else
      Rails.logger.error @automation.errors.inspect
      render json: {errors: @automation.errors}, status: :unprocessable_entity
    end
  end

  # DELETE api/v1/automations/1.json
  def destroy
    @automation.destroy
    head :no_content
  end

  private

  def set_automation
    @automation = Automation.by_project(@project).find(params[:id])
  end

  def automation_params
    # TODO: This needs fixing for sti, take a look at this:
    # https://gist.github.com/danielpuglisi/3c679531672a76cb9a91#file-users_controller-rb
    # TODO: Issue: strong parameters allow hashes with unknown keys to be permitted?
    # https://github.com/rails/rails/issues/9454

    # JSON attributes tags, chef_attributes and environment should be converted to JSON to be able to make a validation in the model.

    # global params
    permited_params = params.permit(:type, :name, :repository, :repository_revision, :timeout)
    params['tags'].blank? ? permited_params.merge!( {'tags' => nil} ) : permited_params.merge!( {'tags' => params[:tags].to_json} )
    # specific params sti
    if params.fetch('type', '').downcase == 'chef'
      permited_params.merge!( params.permit(:log_level) )
      params['chef_attributes'].blank? ? permited_params.merge!( {'chef_attributes' => nil} ) : permited_params.merge!( {'chef_attributes' => params[:chef_attributes].to_json} )
      permited_params.merge!( {'run_list' => params[:run_list]} ) unless params.fetch('run_list', nil).nil?
    elsif params.fetch('type', '').downcase == 'script'
      permited_params.merge!( params.permit(:path) )
      params['environment'].blank? ? permited_params.merge!( {'environment' => nil} ) : permited_params.merge!( {'environment' => params[:environment].to_json} )
      permited_params.merge!( {arguments: params[:arguments]} ) unless params.fetch('arguments', nil).nil?
    end

    return permited_params
  end

end
