Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :merchants do
    resources :dashboard, only: :index
    resources :items, except: :destroy
    resources :invoices, only: [:index, :show]
    resources :invoice_items, only: :update
    resources :bulk_discounts
  end

  resources :admin, only: [:index]

  namespace :admin do
    resources :merchants, except: :destroy
    resources :invoices, only: [:index, :show, :update]
  end

  get '/', to: 'welcome#index'
end
