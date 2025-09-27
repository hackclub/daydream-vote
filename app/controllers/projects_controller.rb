class ProjectsController < ApplicationController
  before_action :require_authentication
  before_action :set_project, only: [:edit, :update]
  
  def select_role
  end
  
  def wait_for_invite
    @pending_invites = CreatorPositionInvite.where(email: current_user.email)
    @accepted_projects = current_user.projects.includes(:creator_positions)
  end
  
  def edit
  end
  
  def update
    # If it's a new project, we need to save it and create the creator position
    if @project.new_record?
      @project.assign_attributes(project_params)
      if @project.save
        # Create the creator position as owner to associate user with project
        @project.creator_positions.create!(user: current_user, role: :owner)
        flash[:notice] = "Project created successfully"
        redirect_to edit_project_path
      else
        flash.now[:alert] = "Please fix the errors below"
        render :edit
      end
    else
      if @project.update(project_params)
        flash[:notice] = "Project updated successfully"
        redirect_to edit_project_path
      else
        flash.now[:alert] = "Please fix the errors below"
        render :edit
      end
    end
  end
  
  private
  
  def require_authentication
    unless signed_in?
      flash[:alert] = "Please sign in first"
      redirect_to new_session_path
    end
  end
  
  def set_project
    @project = current_user.projects.first || build_new_project_for_user
  end
  
  def build_new_project_for_user
    project = Project.new
    # Don't save yet - just build it for the form
    project
  end
  
  def project_params
    params.require(:project).permit(:title, :description, :itchio_url, :repo_url, :image)
  end
end
