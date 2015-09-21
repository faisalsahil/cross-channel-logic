class UsersController < ApplicationController
 #before_filter :authenticate_user!

  def index
    #authorize! :index, @user, :message => 'Not authorized as an administrator.'
    if current_user.blank?
      redirect_to new_user_session_path
    end
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
  
  def update
    authorize! :update, @user, :message => 'Not Authorized as an Administrator.'
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)

      puts "==================="
      if params[:user]["role_ids"] == '1'
       @user.update_attributes(:user_type => 'admin')
      else
       @user.update_attributes(:user_type => 'vip')
      end

      redirect_to users_path, :notice => "User Updated..."
    else
      redirect_to users_path, :alert => "Unable to Update User."
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => 'Not Authorized as an Administrator.'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User Deleted."
    else
      redirect_to users_path, :notice => "Can't Delete Yourself."
    end
  end


  def new
    @user = User.new
  end
  def create_user
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url, :notice=> "Successfully Created."
    else
      flash[:error] = "This Email Id Already Exist."
      redirect_to new_user_path
    end
  end
end