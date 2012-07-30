Campanify::Application.routes.draw do

  resources :pages, :only => [:show], :module => "content"

  devise_for :users
  
  resources :users, :only => [:index, :show] do
    member do
      put :visits
      put :recruited      
    end
  end
  
  ActiveAdmin.routes(self)

  devise_for :administrators, ActiveAdmin::Devise.config

  root :to => "pages#show", :id => Settings.pages["home_page_slug"]
  
end
