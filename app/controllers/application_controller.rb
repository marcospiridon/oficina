class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_workshop

  private

  def set_workshop
    @workshop = Workshop.find_by!(slug: params[:workshop_slug])
  end

  def current_workshop
    @workshop
  end

  def authorize_workshop_access!
    return unless current_user # Allow public access? No, requirement says "protected by user and password"

    unless current_user.workshop_id == @workshop.id || current_user.system_admin?
      flash[:alert] = "You are not authorized to access this workshop."
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(resource)
    if resource.system_admin?
      admin_root_path
    elsif resource.workshop
      workshop_dashboard_path(workshop_slug: resource.workshop.slug)
    else
      root_path
    end
  end

  protected

  def configure_permitted_parameters
    # Allow workshop_name and workshop_slug during sign up
    # Note: This requires custom sign up logic to create the workshop,
    # OR we assume an invite system.
    # For MVP, we'll assume we might need nested attributes or just handle it later.
    # For now, just allow name if we add it to users table.
  end
end
