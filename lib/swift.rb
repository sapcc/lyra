class Swift

  def self.client
    @client ||= SwiftClient.new(
      auth_url:     ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT'],
      username:     ENV['MONSOON_SWIFT_USERNAME'],
      password:     ENV['MONSOON_SWIFT_PASSWORD'],
      user_domain:  ENV['MONSOON_SWIFT_USER_DOMAIN_NAME'],
      user_domain_id:  ENV['MONSOON_SWIFT_USER_DOMAIN_ID'],
      temp_url_key: ENV['MONSOON_SWIFT_TEMP_URL_KEY'],
      project_id:   ENV['MONSOON_SWIFT_PROJECT_ID'],
      project_name:   ENV['MONSOON_SWIFT_PROJECT_NAME'],
      project_domain_name: ENV['MONSOON_SWIFT_PROJECT_DOMAIN_NAME'],
      project_domain_id: ENV['MONSOON_SWIFT_PROJECT_DOMAIN_ID']
    )
  end
end
