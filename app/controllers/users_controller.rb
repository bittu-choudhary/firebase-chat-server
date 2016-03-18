class UsersController < ApplicationController
  def sign_in
    if User.exists?(name: params[:name])
      render :json=> {:success=>true, :user_name=>"#{params[:name]}"}, :status=>200
    else
      render :json=> {:success=>false, :errors=>"user does not exits"}, :status=>401
    end
  end

  def list_users
    all_users = User.all.select(:name,:id)
    render :json=> {:success=>true, :user_array => all_users}, :status=>200
  end

  def start_chat
    from = params[:from]
    to = params[:to]

    firebase = Firebase::Client.new(ENV['BASE_URI'])
    existResponse = firebase.get("users/" + from + "/activeChats/" + to)
    if !existResponse.body
      time = (Time.now.getutc.to_f * 1000).to_i
      response = firebase.set("users/" + from + "/activeChats/" + to, {name: from + "_" +to, from: from, to: to, timestamp: time})
      response = firebase.set("users/" + to + "/activeChats/" + from, {name: from + "_" +to, from: from, to: to, timestamp: time})
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

    firebase = Firebase::Client.new(ENV['BASE_URI'])
    time = (Time.now.getutc.to_f * 1000).to_i
    response = firebase.push("chats/" + channel_name + "/messages", {message: message, from: from, to: to, timestamp: time, read: false})
    render :json=> {success: response.success?}
  end
end
