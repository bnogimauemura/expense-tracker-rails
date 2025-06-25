Rails.application.routes.draw do
  # A simple page to check if the website is working
  get "up" => "rails/health#show", as: :rails_health_check

  # Special routes for editing and deleting many expenses at once
  # These must come BEFORE the normal routes so they work properly
  # - Shows the page where you can edit several expenses
  # - Saves all the changes you made
  # - Deletes several expenses you selected
  post  "/expenses/edit_multiple",   to: "expenses#edit_multiple",   as: :edit_multiple_expenses
  patch "/expenses/update_multiple", to: "expenses#update_multiple", as: :update_multiple_expenses
  delete "/expenses/destroy_multiple", to: "expenses#destroy_multiple", as: :destroy_multiple_expenses

  # Normal routes for doing things with expenses (view, add, edit, delete)
  # These give you the basic ways to work with expenses
  # Note: We don't need :show and :update since we don't have individual expense pages
  resources :expenses, except: [:show, :update]

  # Make the expense list the main page when you visit the website
  root "expenses#index"
end
