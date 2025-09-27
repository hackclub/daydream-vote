class SessionsController < ApplicationController


  def create
    email = params[:email]&.downcase&.strip
    
    if email.blank?
      flash[:alert] = "Please enter an email address"
      render :new and return
    end
    
    user = User.find_or_create_by(email: email)
    token = user.tokens.create!(expires_at: 3.hours.from_now)
    
    LoopsMailer.sign_in_email(user.email, token.id).deliver_later
    
    flash[:notice] = if Rails.env.development?
      "We sent you a login link. #{view_context.link_to('Check Letter Opener', letter_opener_web_path, target: '_blank')}".html_safe
    else
      "We sent you a login link"
    end
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Successfully signed out"
    redirect_to root_path
  end
  
  def verify_token
    token = Token.find_by(id: params[:token_id])
    
    if token&.valid_for_login?
      token.mark_as_used!
      session[:user_id] = token.user.id
      
      # Check if profile data exists
      if token.user.profile_datum.nil?
        flash[:notice] = "Successfully signed in! Please complete your profile information."
        redirect_to edit_profile_path
      else
        flash[:notice] = "Successfully signed in!"
        redirect_to projects_select_role_path
      end
    else
      flash[:alert] = "Invalid or expired login link"
      redirect_to new_session_path
    end
  end
end
