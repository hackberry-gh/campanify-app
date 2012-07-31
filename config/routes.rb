Campanify::Application.routes.draw do

  filter :locale, :exclude => /^\/admin|^\/users\/auth/ if respond_to?('filter')
  
  resources :pages, :only => [:show], :module => "content"
  resources :widgets, :only => [:show], :module => "content"
  
  devise_for :users, :controllers => {
    :registrations => "users/registrations",
    :sessions => "users/sessions",
    :omniauth_callbacks => "users/omniauth_callbacks"    
  }

  resources :users, :only => [:index, :show] do
    member do
      put :visits
    end
  end
  
  ActiveAdmin.routes(self)

  devise_for :administrators, ActiveAdmin::Devise.config

  root :to => "content/pages#show", :id => Settings.pages["home_page_slug"]
  
end
