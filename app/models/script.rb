class Script < Automation

  validates_presence_of :git_url
  validates :git_url, format: { with: URI.regexp }

end