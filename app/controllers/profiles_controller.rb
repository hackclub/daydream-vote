class ProfilesController < ApplicationController
  before_action :require_authentication
  before_action :set_profile_datum

  def edit
  end

  def update
    # Check honesty policy agreement
    unless params[:profile_datum][:honesty_policy_agreement] == "true"
      @profile_datum.assign_attributes(profile_datum_params)
      @profile_datum.errors.add(:honesty_policy_agreement, "must be accepted")
      flash.now[:alert] = "Please fix the errors below"
      render :edit
      return
    end

    if @profile_datum.update(profile_datum_params)
      flash[:notice] = "Profile updated successfully"
      if @profile_datum.user.projects.first.present?
        redirect_to edit_project_path
      else
        redirect_to projects_select_role_path
      end
    else
      flash.now[:alert] = "Please fix the errors below"
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

  def set_profile_datum
    @profile_datum = current_user.profile_datum

    if @profile_datum.nil?
      # Build new profile with Airtable data if available
      airtable_data = ::AirtableService.find_profile_by_email(current_user.email) || {}
      @profile_datum = current_user.build_profile_datum(airtable_data)
    end
  end

  def profile_datum_params
    allowed_params = [ :first_name, :last_name, :dob, :address_line_1,
                                         :address_line_2, :address_city, :address_state,
                                         :address_zip_code, :address_country ]
    params.require(:profile_datum).permit(allowed_params)
  end
end
