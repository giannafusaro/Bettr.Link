BettrLink::Application.routes.draw do

  #####################################
  # API
  #####################################

  # http://andrewberls.com/blog/post/api-versioning-with-rails-4
  # http://railscasts.com/episodes/350-rest-api-versioning

  constraints subdomain: 'api' do
    scope module: 'api', defaults: { format: :json } do
      namespace :v1, as: :api, constraints: Constraints::Api.new(version: 1, default: true) do
        get '/analyze', to: 'links#analyze', as: :analyze
      end
    end
  end

  #####################################
  # Site
  #####################################

  resources :users, :links, :tags

  # match '/login' => 'users#login', via: [:get, :post], as: :login
  post '/login' => 'users#login', as: :login
  get '/logout' => 'users#logout', as: :logout

  get '/:user_name/dashboard' => 'site#dashboard', as: :dashboard
  get '/:user_name/settings' => 'site#settings', as: :settings

  get '/parse' => 'links#parse', as: :parse

  root 'site#home', as: :site_path

end
