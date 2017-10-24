require 'swagger_helper'

RSpec.describe 'Automations API' do
  let(:"X-Auth-Token") { token }
  path '/api/v1/automations' do


    get 'List automations' do
      before do
        script_automation = FactoryGirl.create(:script, project_id: project_id)
        chef_automation = FactoryGirl.create(:chef, project_id: project_id)
      end
      let(:page) { 1 }
      let(:per_page) { 10 }

      #tags "Automations"
      parameter name: :page, in: :query, type: :integer, default: 1
      parameter name: :per_page, in: :query, type: :integer, maximum: 25, default: 10

      response '200', 'list automations' do
        header 'Pagination-Page', type: :integer, description: 'Current page number'
        header 'Pagination-Pages', type: :integer, description: 'Total number of pages'
        header 'Pagination-Per-Page', type: :integer, description: 'Items per page'
        header 'Pagination-Elements', type: :integer, description: 'Total number of items'
        schema type: :array,  items: { '$ref' => '#/definitions/Automation' }
        run_test!
      end

      response '401', 'authorization required' do
        let(:"X-Auth-Token") { "invalid" }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end

    end

    post 'Create automation' do
      parameter name: :body, in: :body, schema: { '$ref' => '#/definitions/Automation' }
      let(:body) { { name: 'test', type: 'Chef', repository: 'http://some-git.repo.git', run_list: [ 'recipe[test]' ]   } }

      response '201', 'automation created' do
        schema '$ref' => '#/definitions/Automation'
        run_test!
      end
      response '401', 'authorization required' do
        let(:"X-Auth-Token") { "invalid" }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end

      response '422', 'unprocessible entity' do
        let(:body) { {} }
        schema '$ref' => '#/definitions/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/automations/{id}' do
    let(:id) { FactoryGirl.create(:script, project_id: project_id).id }
    parameter name: :id, :in => :path, :type => :string, description: "automation id"
    get 'Show automation' do
      produces 'application/json'
      response '200', 'show automation' do
        schema '$ref' => '#/definitions/Automation'
        run_test!
      end
      response '401', 'authorization required' do
        let(:"X-Auth-Token") { "invalid" }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
      response '404', 'not found' do
        let(:id) { 1000 }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
    end

    put 'Update automation' do
      security [ keystone: [] ]
      parameter name: :body, in: :body, schema: { '$ref' => '#/definitions/Automation' }
      response '200', 'update automation' do
        let(:body) { { name: 'test' } }
        schema '$ref' => '#/definitions/Automation'
        run_test! do |response|
        end
      end
      response '401', 'authorization required' do
        let(:"X-Auth-Token") { "invalid" }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
      response '422', 'unprocessible entity' do
        let(:body) { {repository: "invalid"} }
        schema '$ref' => '#/definitions/errors_object'
        run_test!
      end
      response '404', 'not found' do
        let(:id) { 1000 }
        schema '$ref' => '#/definitions/error_object'
        run_test!
      end
    end

    delete 'Delete automation' do
      response '204', 'automation deleted' do
        run_test!
      end
      response '401', 'authorization required' do
        let(:"X-Auth-Token") { "invalid" }
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
