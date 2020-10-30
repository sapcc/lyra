class GitURL

  @@transports = [
    "ssh",
		"git",
		"http",
		"https"]
  SCP_SYNTAX = %r{^([-._~a-zA-Z0-9]+@)?([-.a-zA-Z0-9]+):([^/][-/._a-zA-Z0-9]+)$}

  def self.parse url
    if url=~ SCP_SYNTAX
      userinfo= $1.present? ? $1.chomp('@') : nil
      return URI::Generic.new('ssh', userinfo, $2, nil, nil, '/'+$3, nil, nil, nil)
    else
      u = URI.parse(url)
      raise "unsupported scheme #{u.scheme}" unless @@transports.include?(u.scheme)
      return u
    end
  end

end
