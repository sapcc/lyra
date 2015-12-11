Rails.application.routes.draw do

  namespace "api", constraints: { format: 'json' }, :defaults => { :format => :json } do
    namespace "v1" do
      resources :automations,  only: [:index, :show, :create, :update, :destroy] do
      end
    end
  end

  get :healthcheck, to: "health#show"

end
