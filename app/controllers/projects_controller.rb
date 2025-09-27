class ProjectsController < ApplicationController
  before_action :require_authentication
  before_action :set_project, only: [:edit, :update]
  
  def select_role
  end
  
  def edit
  end
  
  def update
    if @project.update(project_params)
      flash[:notice] = "Project updated successfully"
      redirect_to edit_project_path
    else
      render :edit
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
    @project = current_user.projects.first || current_user.projects.build
  end
  
  def project_params
    params.require(:project).permit(:title, :description, :itchio_url, :repo_url, :image)
  end
end
