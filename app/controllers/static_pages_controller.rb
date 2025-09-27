class StaticPagesController < ApplicationController
  def landing
    if signed_in?
      @progress = :your_info
    end
  end

  def admin_dashboard
    unless signed_in? && current_user.is_admin?
      redirect_to root_path, alert: "You must be an admin to access that page."
      return
    end

    @events = Event.all
    @users = User.all
    @projects = Project.all
    @votes = Vote.all
  end
end
