Campanify::Application.routes.draw do
  devise_for :users

  # root :to => "pages#show", :id => Settings.pages["home_page_slug"]
end
