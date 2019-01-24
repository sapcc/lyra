require File.join(Gem.loaded_specs['monsoon-openstack-auth'].full_gem_path, 'spec/support/authentication_stub')

module AuthLetDeclarations
  extend RSpec::SharedContext
  let(:token) { AuthenticationStub.test_token }
  let(:token_value) { token['value'] }
  let(:current_user) { MonsoonOpenstackAuth::Authentication::AuthUser.new(token) }
  let(:project_id) { AuthenticationStub.project_id }
end

RSpec.configure do |config|
  config.include AuthLetDeclarations
  config.include AuthenticationStub

  config.before :each do
    stub_authentication
  end
end
