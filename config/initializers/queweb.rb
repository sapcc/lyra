Que::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV['QUEWEB_USERNAME'], ENV['QUEWEB_PASSWORD']]
end
