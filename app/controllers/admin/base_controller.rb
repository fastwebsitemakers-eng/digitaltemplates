class Admin::BaseController < ApplicationController
  layout 'admin'
  before_action { redirect_to login_path unless session[:admin] }
end
