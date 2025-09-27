class LoopsMailer < ApplicationMailer
  unless Rails.env.development?
    self.delivery_method = :smtp
    self.smtp_settings = {
      address: "smtp.loops.so",
      port: 587,
      user_name: "loops",
      password: ENV["LOOPS_API_KEY"],
      authentication: "plain",
      enable_starttls: true
    }
  end

  def sign_in_email(email, token)
    @email = email
    @token = token
    @sign_in_url = verify_token_url(token_id: @token)

    mail(
      to: @email,
    )
  end
end