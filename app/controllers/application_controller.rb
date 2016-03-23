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
  scheduler = Rufus::Scheduler.new
  scheduler.every '5m' do
    firebase = Firebase::Client.new(ENV['BASE_URI'],ENV['SECRET_KEY'])
    chats_object = firebase.get("chats")
    chats_object.body.each do |key, value|
      users = key.split("_",2)
      users.each do |user|
        if firebase.get("chats/" + key + "/" + user + "_unreadCount").body > 0
          push_notification = Rpush::Gcm::Notification.new
          push_notification.app = Rpush::Gcm::App.find_by_name(ENV['RPUSH_APP_NAME'])
          message = "You have unread messages"
          title = "You've got a new message"
          p push_notification.app
          p User.find_by(name: user)
          push_notification.registration_ids = [User.find_by(name: user).device_id]
          push_notification.data = { title: title, message: message, user_name: user}
          push_notification.save!
          Rpush.push
        end
      end
    end
  end
end
