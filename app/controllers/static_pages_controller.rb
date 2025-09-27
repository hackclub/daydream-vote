class StaticPagesController < ApplicationController
  def landing
    if signed_in?
      @projects = current_user.projects
    end
  end
end
