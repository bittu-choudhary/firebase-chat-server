class User < ActiveRecord::Base
  def self.fetch_unread_count
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
          push_notification.registration_ids = [User.find_by(name: user).device_id]
          push_notification.data = { title: title, message: message, user_name: user}
          Rpush.push
        end
      end
    end
  end
end
