class OrganizeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :ensure_organizer!

  def index
    @projects = @event.projects.includes(:users, :votes).order(:created_at)
    @visible_projects = @projects.visible
    @hidden_projects = @projects.hidden
  end

  def hide_project
    @project = @event.projects.find(params[:project_id])
    @project.hide!
    redirect_to organize_event_path(@event), notice: "Project hidden successfully"
  end

  def unhide_project
    @project = @event.projects.find(params[:project_id])
    @project.unhide!
    redirect_to organize_event_path(@event), notice: "Project unhidden successfully"
  end

  def toggle_voting
    @event.update!(voting_enabled: !@event.voting_enabled)
    status = @event.voting_enabled ? "opened" : "closed"
    redirect_to organize_event_path(@event), notice: "Voting has been #{status}."
  end

  private

  def set_event
    @event = Event.find_by!(name: params[:event_slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Event not found"
  end

  def ensure_organizer!
    unless current_user.organizer_positions.exists?(event: @event)
      redirect_to root_path, alert: "Access denied. You must be an organizer for this event."
    end
  end

  def authenticate_user!
    redirect_to root_path, alert: "Please sign in" unless signed_in?
  end
end
