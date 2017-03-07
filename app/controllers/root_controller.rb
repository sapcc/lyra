class RootController < ActionController::Base
  @@revison = `git rev-parse HEAD`.strip
  def show 
    render json: {name: "Lyra", revision: @@revison }, status: 200
  end
end
