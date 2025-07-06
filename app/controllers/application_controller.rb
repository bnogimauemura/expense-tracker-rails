class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  public

  # Temporary route for testing monthly report modal
  def reset_visit_date
    if user_signed_in?
      current_user.update!(last_visit_date: nil)
      redirect_to expenses_path, notice: "Visit date reset! Monthly report should appear on next page load."
    else
      redirect_to expenses_path, alert: "Please log in first."
    end
  end

  # Simple test route
  def test_route
    render html: "<h1>Test route works!</h1>".html_safe
  end
end
