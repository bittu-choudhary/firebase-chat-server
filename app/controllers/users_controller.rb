class UsersController < ApplicationController
  require "firebase_token_generator"
  def sign_in
    if User.exists?(name: params[:name])
      user = User.find_by(name: params[:name])
      user.device_id = params[:device_id]
      payload = { :uid => params[:name]}
      generator = Firebase::FirebaseTokenGenerator.new(ENV['SECRET_KEY'])
      token = generator.create_token(payload)
      user.save
      render :json=> {:success=>true, :user_name=>"#{params[:name]}", :auth_token => "#{token}"}, :status=>200
    else
      render :json=> {:success=>false, :errors=>"user does not exits"}, :status=>401
    end
  end

  def fetch_unread_count
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
          push_notification.save!
          Rpush.push
        end
      end
    end
  end

  def list_users
    all_users = User.all.select(:name,:id)
    render :json=> {:success=>true, :user_array => all_users}, :status=>200
  end

  def start_chat
    from = params[:from]
    to = params[:to]

    firebase = Firebase::Client.new(ENV['BASE_URI'],ENV['SECRET_KEY'])
    existResponse = firebase.get("users/" + from + "/activeChats/" + to)
    p existResponse
    if !existResponse.body
      time = (Time.now.getutc.to_f * 1000).to_i
      response = firebase.set("users/" + from + "/activeChats/" + to, {name: from + "_" +to, from: from, to: to, timestamp: time, profile_url: "http://dev.moldedbits.com/wp-content/uploads/2013/10/DSC_0145_111.jpg" })
      response = firebase.set("users/" + to + "/activeChats/" + from, {name: from + "_" +to, from: from, to: to, timestamp: time, profile_url: "http://moldedbits.com/wp-content/uploads/2013/10/DSC_2249_1.jpg"})
      render :json=> {success: response.success?}
    else
      render :json=> {success: true}
    end
  end

  def send_message
    from = params[:from]
    to = params[:to]
    channel_name = params[:channel_name]
    message = params[:message]

    firebase = Firebase::Client.new(ENV['BASE_URI'],ENV['SECRET_KEY'])
    time = (Time.now.getutc.to_f * 1000).to_i
    response = firebase.push("chats/" + channel_name + "/messages", {message: message, from: from, to: to, timestamp: time, read: false})
    render :json=> {success: response.success?}
  end
end
