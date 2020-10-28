# frozen_string_literal: true

class Api::V1::AutomationsController < ApplicationController
  api_authentication_required rescope: false # do not rescope after authentication
  authorization_required

  before_action :require_project
  before_action :set_automation, only: %i[show edit update destroy]

  # GET api/v1/automations.json
  def index
    @automations = Automation.by_project_all(@project, params[:page], params[:per_page])
    @automations[:pagination].headers(response)
    render json: @automations[:elements]
  end

  # GET /automations/1.json
  def show
    render json: @automation
  end

  # POST api/v1/automations.json
  def create
    @automation = Automation.new(automation_sliced_params.merge!(project_id: @project))

    if @automation.save
      render json: @automation, status: :created
    else
      Rails.logger.error @automation.errors.inspect
      render json: { errors: @automation.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT api/v1/automations/1.json
  def update
    if @automation.update(automation_sliced_params(@automation.type))
      render json: @automation, status: :ok
    else
      Rails.logger.error @automation.errors.inspect
      render json: { errors: @automation.errors }, status: :unprocessable_entity
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

  def automation_sliced_params(type = nil)
    permitted = %i[name repository repository_revision repository_credentials timeout]
    if type.nil?
      permitted.push(:type)
      type = params[:type]
    end

    case type
    when 'Chef'
      permitted.push(:debug, :chef_version, :run_list, :chef_attributes)
    when 'Script'
      permitted.push(:path, :arguments, :environment)
    end

    HashWithIndifferentAccess.new(params.to_unsafe_h).slice(*permitted)
  end

  def automation_params(type = nil)
    permitted = %i[name repository repository_revision timeout]
    if type.nil?
      permitted.push(:type)
      type = params[:type]
    end

    case type
    when 'Chef'
      permitted.push(:debug, :chef_version, { run_list: [] }, chef_attributes: permit_recursive_params(params[:chef_attributes]))
    when 'Script'
      env = params[:environment].try(:keys)
      permitted.push(:path, arguments: [], environment: (env.blank? ? {} : env))
    end

    params.permit(*permitted)
  end

  def permit_recursive_params(params)
    return params if params.blank?

    (params.try(:to_unsafe_h) || params).map do |key, value|
      if value.is_a?(Array)
        if value.first.respond_to?(:map)
          { key => [permit_recursive_params(value.first)] }
        else
          { key => [] }
        end
      elsif value.is_a?(Hash)
        { key => permit_recursive_params(value) }
      else
        key
      end
    end
  end
end
