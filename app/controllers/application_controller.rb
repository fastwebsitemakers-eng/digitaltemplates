class ApplicationController < ActionController::Base
  before_action { @s = SiteSetting.values }
end
