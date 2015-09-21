class ManagesController < ApplicationController

  def index
    if current_user.present?
    @manage = Manage.new
    else
      flash[:error] = "Please Login First."
      redirect_to new_user_session_path
    end
  end

  def search_subscriber
   if current_user.present?
      @email = params[:manage][:email]
      @ticket_number = params[:manage][:tickeck_id]

      @member = UploadCsv.where(:email=>@email,:tickect_id=>@ticket_number)
      #@apisetting = Apisetting.first
      #@list_id = @apisetting.list
      #@api_key = @apisetting.api_key

      #gb = Gibbon::API.new(@api_key)
      #Gibbon::API.api_key = @api_key
      #Gibbon::API.timeout = 15
      #Gibbon::API.throws_exceptions = false
      #@lists = Gibbon::API.lists.list
      #@listloaded = []
      #@lists['data'].each_with_index do |list, index|
      #  @listloaded[index] = {}
      #  if @list_id ==  list["id"]
      #    @list_name = list["name"]
      # end
      #end
      if @member.blank?
        flash[:error] = "Please Enter Correct Email and Ticket Number."
        redirect_to manages_path
      else
        @user = User.find_by_id(@member.first.remove_user)
      end
   else
     flash[:error] = "Please Login First."
     redirect_to new_user_session_path
   end
  end

    def unsubscribe
      if current_user.present?
        @apisetting = Apisetting.first
        #@list_id = @apisetting.list
        @api_key = @apisetting.api_key
        @date = DateTime.now.to_date
        @date = @date.strftime("%m-%d-%Y")
        @list_id = params[:list_id]

        gb = Gibbon::API.new(@api_key)
        Gibbon::API.api_key = @api_key
        Gibbon::API.timeout = 15
        Gibbon::API.throws_exceptions = false


        flag = Gibbon::API.lists.unsubscribe(:id =>  @list_id,  :email => {:email => params[:email]}, :delete_member => true,
                                             :send_goodbye => false, :send_notify => false)

        if !defined?(flag.status)
             @member = UploadCsv.find_by_tickect_id(params[:ticket_id])
            if @member.present?
                  @member.update_attributes('follow_up'=> "N", 'remove_date'=> @date, 'remove_user'=> current_user.id, 'message_sent'=> '1')
                  redirect_to  manage_path(@member),:notice=>"Success! The contact has been removed from MailChimp and the follow up system."
            else
              redirect_to new_manage_path, :notice=>"Not Found from Local DB."
            end
        else
           redirect_to new_manage_path, :notice=>"Not Unsubscribe."
        end
      else
        flash[:error] = "Please Login First."
        redirect_to new_user_session_path
    end

    end

  def show
    @member = UploadCsv.find(params[:id])
    @user = User.find_by_id(@member.remove_user)
  end
end

