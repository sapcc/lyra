MonsoonOpenstackAuth.configure do |auth|
  auth.connection_driver.api_endpoint = ENV['MONSOON_OPENSTACK_AUTH_API_ENDPOINT']
  auth.connection_driver.ssl_verify_peer = false

  # optional, default=true
  auth.token_auth_allowed = true
  # optional, default=true
  auth.basic_auth_allowed = false
  # optional, default=true
  auth.sso_auth_allowed   = false
  # optional, default=true
  auth.form_auth_allowed  = false
  # optional, default=false
  auth.access_key_auth_allowed = false

  # optional, default= last url before redirected to form
  #auth.login_redirect_url = -> referrer_url, current_user { after_login_url(referrer_url, current_user)}

  # authorization policy file
  # auth.authorization.policy_file_path = policy_paths
  # context: Default is name of main app, e.g. dashboard.
  # If you overwrite context, rules in policy file should begin with that context.
  # auth.authorization.context = "identity"


  #auth.authorization.trace_enabled = true
  # auth.authorization.reload_policy = true
  # auth.authorization.trace_enabled = true
  #
  # auth.authorization.controller_action_map = {
  #   :index   => 'read',
  #   :show    => 'read',
  #   :new     => 'create',
  #   :create  => 'create',
  #   :edit    => 'update',
  #   :update  => 'update',
  #   :destroy => 'delete'
  # }

  # config.authorization.security_violation_handler: Error handler method which is called when MonsoonOpenstackAuth::Authorization::SecurityViolation appears.
  # Default setting is  :authorization_forbidden.
  # You can specify another handler or overwrite "authorization_forbidden" method in controller.
  security_violation_handler = :authorization_forbidden

  # optional, default=false
  auth.debug=true
end

