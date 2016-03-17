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
    firebase = Firebase::Client.new(ENV['base_uri'], ENV['secret_key'])
  end
end
