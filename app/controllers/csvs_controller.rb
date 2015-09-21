class CsvsController < ApplicationController

def new
  if current_user && current_user.user_type=="admin"
     @csv = Csv.new
     @apisetting = Apisetting.first
     if (@apisetting && @apisetting.api_key.present?)


     @api_key = @apisetting.api_key
     if @api_key.present?
         gb = Gibbon::API.new(@api_key)
         Gibbon::API.api_key = @api_key
         Gibbon::API.timeout = 15
         Gibbon::API.throws_exceptions = false

         # ------------load lists--------------

         @lists = Gibbon::API.lists.list
          if @lists.present?
           @listloaded = []
           @lists['data'].each_with_index do |list, index|
             @listloaded[index] = {}
             @listloaded[index]["id"] = list["id"]
             @listloaded[index]["name"] = list["name"]
           end
          end
     else
          redirect_to new_apisetting_path,:notice=>"No Api Key Found!"
     end
     end
  else
    flash[:error] = "Please Login First."
     redirect_to new_user_session_path
  end
end
  #///////////////////////// pdf create here ///////////////////////////////
  def create
    if current_user && current_user.user_type == "admin"
       if params[:csv][:csv].present?
            @upload_csv = UploadCsv.find_by_id(params[:csv][:upload_csv_id])
            @csv = @upload_csv.csv || Csv.new
            @csv.csv = params[:csv][:csv]
            @csv.upload_csv = @upload_csv
            @csv.csv_url = @csv.csv.url
            if @csv.save
              redirect_to upload_csvs_path, :notice=> "Successfully Uploaded."
            else
              flash[:error] = "Please Select *.pdf File."
              puts"============================elsesssssssss==================================="
              redirect_to :back
            end
       else
         flash.now[:error] = "Please Select *.pdf File."
         redirect_to new_upload_csv_path({:upload_csv_id=>params[:upload_csv_id]}), :notice=>"Please Select PDF File."
       end
    else
      flash[:error] = "Please Login First."
      redirect_to new_user_session_path
    end


  end

  def import
    if current_user && current_user.user_type == "admin"
      if params[:csv][:csv].present? && params[:csv][:list_id].present?
        @list_id = params[:csv][:list_id]
        @error_arr = []

        #file = params[:csv][:csv]
        #extension = file.extension.downcase
        Csv.import(params[:csv][:csv],@list_id,@error_arr)
        redirect_to upload_csvs_path({:error_array=>@error_arr}), :notice=> "List Imported."
      else
        flash[:error] = "Please Select *.csv File and List Type."
        redirect_to new_csv_path
      end
    else
      flash[:error] = "Please Login First."
      redirect_to new_user_session_path
    end

  end

  #////////////// pdf url click //////////////////////////////
  def show
    @csv = Csv.find_by_id(params[:id])
    if @csv.present?
      @date = DateTime.now.to_date
      @date = @date.strftime("%m-%d-%Y")
      @csv.upload_csv.update_attributes(:follow_up => "N", :clicked_link_date=>@date)
      redirect_to @csv.csv_url
   end
  end

      #////////////////  Approved or Cancel url click //////////////////

  def approved
    puts"========================== Approved ===================================="
    @csv = Csv.find_by_id(params[:id])
    if @csv.present?
      @date = DateTime.now.to_date
      @date = @date.strftime("%m-%d-%Y")
      @approved = params[:approved]
      if  @approved == '1'
        @csv.upload_csv.update_attributes(:approved => "Y", :approved_date => @date)
        redirect_to root_url
      elsif @approved == '0'
        @csv.upload_csv.update_attributes(:approved => "N", :approved_date=>@date)
        redirect_to root_url
      end

    end
  end

end
