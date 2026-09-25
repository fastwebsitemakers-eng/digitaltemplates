class SessionsController < ApplicationController
  layout 'admin'
  def new; end

  def create
    if ActiveSupport::SecurityUtils.secure_compare(params[:password].to_s, ENV.fetch('ADMIN_PASSWORD', 'admin'))
      reset_session
      session[:admin] = true
      redirect_to admin_root_path
    else
      flash.now[:alert] = 'Wrong password'
      render :new, status: 422
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
