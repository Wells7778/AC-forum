Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show, :edit, :update] do
    member do
      get :comments
      get :collects
      get :drafts
      get :friends
    end
  end
  resources :posts do
    resources :comments, only: [:create, :destroy]
    member do
      post :collect
      post :uncollect
    end
  end
  resources :friendships, only: :create do
    member do
      post :accept
      delete :ignore
    end
  end
  resources :feeds, only: :index

  root "posts#index"

  namespace :api, defaults: {format: :json} do
    namespace :v1 do

      post "/login" => "auth#login"
      post "/logout" => "auth#logout"

      resources :posts, only: [:index, :create, :show, :update, :destroy]
    end
  end
  # routes for admin
  namespace :admin do
    resources :categories
    resources :users, only: [:index, :update]

    root "categories#index"
  end
end
