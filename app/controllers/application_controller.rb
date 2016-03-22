class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  if Rpush::Gcm::App.find_by_name(ENV['RPUSH_APP_NAME']).nil?
    app = Rpush::Gcm::App.new
    app.name = ENV['RPUSH_APP_NAME']
    app.auth_key = ENV['GCM_AUTH_KEY']
    app.connections = 1
    app.save!
  end
end
