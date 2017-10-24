class RootController < ActionController::Base
  @@revison = `git rev-parse HEAD`.strip
  def show
    respond_to do |format|
      format.json { render json: {name: "Lyra", revision: @@revison }, status: 200 }
      format.html { redirect_to '/api-docs/' }
    end
  end
end
