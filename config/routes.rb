Rails.application.routes.draw do
  namespace 'api', constraints: { format: 'json' }, defaults: { format: :json } do
    namespace 'v1' do
      resources :automations, only: %i[index show create update destroy] do
      end
      resources :runs, only: %i[index show create] do
      end
    end
  end

  get :healthcheck, to: 'health#show'

  require 'que/web'
  mount Que::Web => '/que'

  root to: 'root#show'
end
