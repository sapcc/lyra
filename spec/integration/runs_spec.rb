require 'swagger_helper'

RSpec.describe 'Automations API' do
  before do
    token['roles'].delete_if { |h| h['id'] == 'automation_role' }
    token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
  end
  let(:"X-Auth-Token") { token_value }
  let(:automation) { FactoryGirl.create(:chef, project_id: project_id) }

  path '/api/v1/runs' do
    get 'List runs' do
      before do
        FactoryGirl.create(:run, automation: automation, job_id: 'some-job-id', repository_revision: 'nase')
      end
      let(:page) { 1 }
      let(:per_page) { 10 }

      parameter name: :page, in: :query, type: :integer, default: 1
      parameter name: :per_page, in: :query, type: :integer, maximum: 25, default: 10

      response '200', 'list runs' do
        header 'Pagination-Page', type: :integer, description: 'Current page number'
        header 'Pagination-Pages', type: :integer, description: 'Total number of pages'
        header 'Pagination-Per-Page', type: :integer, description: 'Items per page'
        header 'Pagination-Elements', type: :integer, description: 'Total number of items'
        schema type: :array, items: { '$ref' => '#/definitions/Run' }
        run_test!
      end
      response '401', 'authorization required' do
        let(:"X-Auth-Token") { 'invalid' }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
    end

    post 'Create run' do
      description 'Execute an automation on one or more instances.'
      parameter name: :body, in: :body, schema: { '$ref' => '#/definitions/Run' }
      let(:body) { { automation_id: automation.id, selector: "bla = 'fasel'" } }
      response '201', 'run created' do
        schema '$ref' => '#/definitions/Run'
        run_test!
      end
      response '401', 'authorization required' do
        let(:"X-Auth-Token") { 'invalid' }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
      response '404', 'not found' do
        let(:body) { { automation_id: 1000, selector: "bla = 'fasel'" } }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
    end
  end

  path '/api/v1/runs/{id}' do
    let(:id) { FactoryGirl.create(:run, automation: automation, job_id: 'some-job-id').id }
    parameter name: :id, in: :path, type: :string, description: 'run id'
    get 'Show run' do
      response '200', 'show run' do
        schema '$ref' => '#/definitions/Run'
        run_test!
      end
      response '401', 'authorization required' do
        let(:"X-Auth-Token") { 'invalid' }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
      response '404', 'not found' do
        let(:id) { 1000 }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
    end
  end
end
