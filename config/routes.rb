Campanify::Application.routes.draw do

  filter :locale, :exclude => /^\/admin|^\/users\/auth|^\/templates/ if respond_to?('filter')
  
  if Settings.modules.include?("events")
    resources :events,  :module => "content", :only => [:index, :show] do
      collection do
        get 'page/:page', :action => :index
      end
    end
  end
  
  if Settings.modules.include?("posts")  
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
    resources :media,   :module => 'content', :only => [:create, :new]
  end
  
  if Settings.modules.include?("analytics") 
    match "analytics" => "analytics#index", :as => :analytics
    match "analytics/map" => "analytics#map"
    match "analytics/ranking" => "analytics#ranking"        
    match "analytics/graphs" => "analytics#graphs"            
  end

  if Settings.modules.include?("media")
    resources :media,   :module => 'content', :only => [:index, :show]
  end
  
  resources :pages,   :module => "content", :only => [:show]
  resources :widgets, :module => "content", :only => [:show]
  
  devise_for :users, :controllers => {
    :registrations => "users/registrations",
    :sessions => "users/sessions",
    :omniauth_callbacks => "users/omniauth_callbacks",
    :invitations => "users/invitations"
  }

  devise_scope :user do
    post "users/invitation/send" => "users/invitations#send_to_contacts"
  end

  if Settings.modules.include?("users")
    resources :users, :only => [:index, :show] do
      collection do
        get 'page/:page', :action => :index
      end
      member do
        put :visits
      end
    end
  end
  
  ActiveAdmin.routes(self)

  devise_for :administrators, ActiveAdmin::Devise.config

  root :to => "content/pages#show", :id => Settings.pages["home_page_slug"]
  
  # Last route in routes.rb
  match '*a', :to => 'errors#routing'
end
