Campanify::Application.routes.draw do

  filter :locale, :exclude => /^\/admin|^\/users\/auth|^\/templates/ if respond_to?('filter')
  
  resources :events,  :module => "content", :only => [:index, :show] do
    collection do
      get 'page/:page', :action => :index
    end
  end
  resources :posts,   :module => "content", :only => [:index, :show, :create, :update, :destroy] do
    collection do
      get 'page/:page', :action => :index
      post 'preview'
    end
    member do
      put 'like'
      put 'unlike'      
    end
  end
  resources :pages,   :module => "content", :only => [:show]
  resources :widgets, :module => "content", :only => [:show]
  
  devise_for :users, :controllers => {
    :registrations => "users/registrations",
    :sessions => "users/sessions",
    :omniauth_callbacks => "users/omniauth_callbacks"    
  }

  resources :users, :only => [:index, :show] do
    collection do
      get 'page/:page', :action => :index
    end
    member do
      put :visits
    end
  end
  
  ActiveAdmin.routes(self)

  devise_for :administrators, ActiveAdmin::Devise.config

  root :to => "content/pages#show", :id => Settings.pages["home_page_slug"]
  
end
