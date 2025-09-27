class ProfilesController < ApplicationController
  before_action :require_authentication
  before_action :set_profile_datum
  
  def edit
  end

  def update
    if @profile_datum.update(profile_datum_params)
      flash[:notice] = "Profile updated successfully"
      redirect_to edit_profile_path
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
  
  def set_profile_datum
    @profile_datum = current_user.profile_datum || current_user.create_profile_datum!
  end
  
  def profile_datum_params
    params.require(:profile_datum).permit(:first_name, :last_name, :dob, :address_line_1, 
                                         :address_line_2, :address_city, :address_state, 
                                         :address_zip_code, :address_country, :attending_event)
  end
end
