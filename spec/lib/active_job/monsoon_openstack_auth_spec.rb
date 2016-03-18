require 'rails_helper'
require 'active_job/monsoon_openstack_auth'

class TestJob < ActiveJob::Base
  include ActiveJob::MonsoonOpenstackAuth

  def perform(*args); end
end

RSpec.describe ActiveJob::MonsoonOpenstackAuth do

  it 'authenticates a token given as first argument' do
    t = TestJob.new(token)
    t.perform_now
    expect(t.current_user).to be_kind_of ::MonsoonOpenstackAuth::Authentication::AuthUser
  end
  it 'authenticates a token given as a hash key' do
    t = TestJob.new(token: token)
    t.perform_now
    expect(t.current_user).to be_kind_of ::MonsoonOpenstackAuth::Authentication::AuthUser

    t = TestJob.new('token' => token)
    t.perform_now
    expect(t.current_user).to be_kind_of ::MonsoonOpenstackAuth::Authentication::AuthUser
  end
end

