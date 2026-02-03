class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home], raise: false

  def home
    if user_signed_in? && current_user.workshop
      redirect_to workshop_dashboard_path(workshop_slug: current_user.workshop.slug)
    end
  end
end
