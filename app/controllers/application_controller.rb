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
  scheduler = Rufus::Scheduler.singleton
  p "just after scheduler object"
  scheduler.every '5m' do
    firebase = Firebase::Client.new(ENV['BASE_URI'],ENV['SECRET_KEY'])
    p "im here"
    chats_object = firebase.get("chats")
    p "chats_object"
    p chats_object
    chats_object.body.each do |key, value|
      users = key.split("_",2)
      users.each do |user|
          p "now im here with " + user
        if !firebase.get("chats/" + key + "/" + user + "_unreadCount").body.nil? && firebase.get("chats/" + key + "/" + user + "_unreadCount").body > 0
          p "sending push"
          push_notification = Rpush::Gcm::Notification.new
          push_notification.app = Rpush::Gcm::App.find_by_name(ENV['RPUSH_APP_NAME'])
          message = "You have unread messages"
          title = "You've got a new message"
          p "app"
          p push_notification.app
          p "user"
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
