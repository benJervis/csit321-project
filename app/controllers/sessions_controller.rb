class SessionsController < ApplicationController

  skip_before_action :require_login, only: [:new, :create]

  def new
    @login_page = true
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      @login_page = true
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end