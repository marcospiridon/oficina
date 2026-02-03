class Admin::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout 'admin'

  private

  def check_admin
    unless current_user.system_admin?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
