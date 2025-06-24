Rails.application.routes.draw do
  # Health check route for uptime monitoring
  get "up" => "rails/health#show", as: :rails_health_check

  # RESTful routes for expenses (index, new, create, edit, update, show, delete)
  resources :expenses, except: [:show, :update]

  # Custom routes for centralized multi-editing
  # - Shows form for selected expenses
  # - Submits updates for all selected items
  post  "/expenses/edit_multiple",   to: "expenses#edit_multiple",   as: :edit_multiple_expenses
  patch "/expenses/update_multiple", to: "expenses#update_multiple", as: :update_multiple_expenses
  delete "/expenses/destroy_multiple", to: "expenses#destroy_multiple", as: :destroy_multiple_expenses

  # Set root path to the expense list
  root "expenses#index"
end
