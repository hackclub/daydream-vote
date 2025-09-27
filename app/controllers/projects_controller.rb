class ProjectsController < ApplicationController
  before_action :require_authentication
  before_action :set_project, only: [ :edit, :update, :review, :submit ]

  def select_role
  end

  def wait_for_invite
    @pending_invites = CreatorPositionInvite.where(email: current_user.email)
    @accepted_projects = current_user.projects.includes(:creator_positions)

    if turbo_frame_request_id == "invite_status"
      render partial: "invite_status"
    end
  end

  def invite_members
    @project = current_user.projects.first
    redirect_to edit_project_path unless @project.present?
  end

  def create_invite
    @project = current_user.projects.first
    redirect_to edit_project_path and return unless @project&.draft?

    email = params[:email]&.strip&.downcase

    if email.blank?
      flash[:alert] = "Email is required"
      redirect_to projects_invite_members_path and return
    end

    # Check if user is already a team member
    if @project.users.joins(:creator_positions).where(users: { email: email }).exists?
      flash[:alert] = "User is already a team member"
      redirect_to projects_invite_members_path and return
    end

    # Check if invite already exists
    if @project.creator_position_invites.where(email: email).exists?
      flash[:alert] = "Invite already sent to this email"
      redirect_to projects_invite_members_path and return
    end

    # Create the invite
    invite = @project.creator_position_invites.create!(
      email: email,
      invited_by: current_user
    )

    # Send the invite email
    LoopsMailer.invite_email(invite).deliver_now

    flash[:notice] = "Invite sent successfully to #{email}"
    redirect_to projects_invite_members_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Failed to send invite: #{e.message}"
    redirect_to projects_invite_members_path
  end

  def vote
    event_param = params[:event]

    # Validate the event exists
    @event = Event.find_by(name: event_param)
    unless @event
      flash[:alert] = "Invalid event"
      redirect_to root_path and return
    end

    # Check if user has a submitted project for this specific event
    current_user_project = current_user.projects.joins(:creator_positions)
                                      .where(attending_event: @event, aasm_state: :submitted)
                                      .first

    unless current_user_project
      flash[:alert] = "You must have a submitted project for this event to vote"
      redirect_to edit_project_path and return
    end

    # Get submitted projects from the same event, excluding current user's projects
    @projects = Project.where(attending_event: @event)
                      .where(aasm_state: :submitted)
                      .where.not(id: current_user.projects.pluck(:id))
                      .includes(:users, :creator_positions)
  end

  def make_vote_selection
    event_param = params[:event]

    @event = Event.find_by(name: event_param)
    unless @event
      flash[:alert] = "Invalid event"
      redirect_to root_path and return
    end

    # Check if user has a submitted project for this specific event
    current_user_project = current_user.projects.joins(:creator_positions)
                                      .where(attending_event: @event, aasm_state: :submitted)
                                      .first

    unless current_user_project
      flash[:alert] = "You must have a submitted project for this event to vote"
      redirect_to edit_project_path and return
    end

    voted_projects = Project.where(id: params[:project_votes].keys)

    if voted_projects.count > 3
      flash[:alert] = "You can only vote for up to 3 projects"
      redirect_to event_vote_path(@event.name) and return
    end

    Vote.transaction do
      # remove existing votes
      current_user.votes.where(event: @event).destroy_all
      # create new votes
      voted_projects.each do |project|
        current_user.votes.create!(project: project)
      end
    end

    redirect_back_or_to event_vote_path(@event.name), notice: "Your votes have been recorded"
  end

  def delete_invite
    @project = current_user.projects.first
    redirect_to edit_project_path and return unless @project

    invite = @project.creator_position_invites.find(params[:invite_id])

    # Only the invite creator can delete the invite
    unless invite.invited_by == current_user
      flash[:alert] = "You can only delete invites you created"
      redirect_to projects_invite_members_path and return
    end

    invite.destroy!

    flash[:notice] = "Invite deleted successfully"
    redirect_to projects_invite_members_path
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Invite not found"
    redirect_to projects_invite_members_path
  end

  def accept_invite
    invite = CreatorPositionInvite.find_by(token: params[:token])

    unless invite
      flash[:alert] = "Invite not found or expired"
      redirect_to root_path and return
    end

    if invite.expired?
      flash[:alert] = "This invite has expired"
      redirect_to root_path and return
    end

    # Check if user is already part of this project
    if invite.project.users.include?(current_user)
      flash[:notice] = "You are already part of this project"
      redirect_to edit_project_path and return
    end

    if invite.accept!(current_user)
      flash[:notice] = "Successfully joined #{invite.project.title}!"
      redirect_to edit_project_path
    else
      flash[:alert] = "Failed to accept invite"
      redirect_to root_path
    end
  end

  def edit
  end

  def review
  end

  def submit
    @project.mark_submitted!
    flash[:notice] = "Project submitted successfully"
    redirect_to edit_project_path
  end

  def update
    # If it's a new project, we need to save it and create the creator position
    if @project.new_record?
      @project.assign_attributes(project_params)
      if @project.save
        # Create the creator position as owner to associate user with project
        @project.creator_positions.create!(user: current_user, role: :owner)
        flash[:notice] = "Project created successfully"
        redirect_to projects_invite_members_path
      else
        flash.now[:alert] = "Please fix the errors below"
        render :edit
      end
    else
      if @project.update(project_params)
        flash[:notice] = "Project updated successfully"
        redirect_to projects_invite_members_path
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

  def require_no_pending_invites
    @project = current_user.projects.first
    if @project&.has_pending_invites?
      flash[:alert] = "You must resolve all pending invites before continuing"
      redirect_to projects_invite_members_path
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
    params.require(:project).permit(:title, :description, :itchio_url, :repo_url, :image, :attending_event_id)
  end
end
