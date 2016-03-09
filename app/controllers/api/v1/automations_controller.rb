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
      # TODO: This needs fixing for sti, take a look at this:
      # https://gist.github.com/danielpuglisi/3c679531672a76cb9a91#file-users_controller-rb
      # TODO: Issue: strong parameters allow hashes with unknown keys to be permitted?
      # https://github.com/rails/rails/issues/9454

      # global params
      permited_params = params.require(:automation).permit(:type, :name, :repository, :repository_revision, :timeout)
      permited_params.merge!( {'tags' => params[:automation][:tags]} ) unless params.fetch('automation', {}).fetch('tags', nil).nil?
      # specific params sti
      if params.fetch('automation', {}).fetch('type', '').downcase == 'chef'
        permited_params.merge!( params.require(:automation).permit(:log_level) )
        permited_params.merge!( {'chef_attributes' => params[:automation][:chef_attributes]} ) unless params.fetch('automation', {}).fetch('chef_attributes', nil).nil?
        permited_params.merge!( {'run_list' => params[:automation][:run_list]} ) unless params.fetch('automation', {}).fetch('run_list', nil).nil?
      elsif params.fetch('automation', {}).fetch('type', '').downcase == 'script'
        permited_params.merge!( params.require(:automation).permit(:path) )
        permited_params.merge!( {environment: params[:automation][:environment]} ) unless params.fetch('automation', {}).fetch('environment', nil).nil?
        permited_params.merge!( {arguments: params[:automation][:arguments]} ) unless params.fetch('automation', {}).fetch('arguments', nil).nil?
      end

      return permited_params
    end

    def set_project
      @project = current_user.project_id
      if @project.nil? || @project.blank?
        render :json  => "{'error':'Project id not found in token.'}".to_json, :status => :forbidden
      end
    end

end
