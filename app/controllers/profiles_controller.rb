class ProfilesController < ApplicationController
  before_action :require_authentication
  before_action :set_profile_datum
  
  def edit
  end

  def update
    if @profile_datum.update(profile_datum_params)
      flash[:notice] = "Profile updated successfully"
      # Check if this is first time completing profile
      if session[:first_profile_completion]
        session.delete(:first_profile_completion)
        redirect_to projects_select_role_path
      else
        redirect_to edit_profile_path
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
      # Build new profile with Airtable data if available (only for first-time users)
      airtable_data = session[:first_profile_completion] ? 
                       ::AirtableService.find_profile_by_email(current_user.email) || {} : 
                       {}
      @profile_datum = current_user.build_profile_datum(airtable_data)
    end
  end
  
  def profile_datum_params
    params.require(:profile_datum).permit(:first_name, :last_name, :dob, :address_line_1, 
                                         :address_line_2, :address_city, :address_state, 
                                         :address_zip_code, :address_country, :attending_event)
  end
end
