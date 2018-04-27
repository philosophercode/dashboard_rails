Rails.application.routes.draw do
  
  devise_for :users, :controllers => { registrations: 'registrations' }
  # devise_for :users
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => "/sidekiq"
  
  resources :websites
  resources :categories
  get 'welcome/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  

  root 'welcome#index'
end
