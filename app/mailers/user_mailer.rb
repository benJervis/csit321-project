class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user

    mail to: "#{user.name} <#{user.email}>", subject: 'Welcome to civitasCRM'
  end

  def password_notification(user)
    @user = user

    mail to: "#{user.name} <#{user.email}>", subject: "Your password has been updated"
  end

  def password_reset(user)
    @user = user

    mail to: "#{user.name} <#{user.email}>", subject: 'Password Reset'
  end

  def account_setup(user)
    @user = user

    mail to: "#{user.name} <#{user.email}>", subject: 'Welcome to civitasCRM'
  end
end
