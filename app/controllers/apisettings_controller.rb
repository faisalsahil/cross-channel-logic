class ApisettingsController < ApplicationController

  def new
   if current_user && current_user.user_type=="admin"
      @apisetting = Apisetting.first
      if @apisetting.blank?
         @apisetting = Apisetting.new
         @key_mandrill = KeyMandrill.first
         if !@key_mandrill.present?
           @key_mandrill = KeyMandrill.new
         else
           m = Mandrill::API.new(@key_mandrill.key)
           if defined?(m.templates.list.class)
             result = m.templates.list
             @list_template = []
             result.each_with_index do |template,index|
               @list_template << template["name"]
             end
           end
         end
         @smtp_setting = SmtpSetting.first
         if !@smtp_setting.present?
           @smtp_setting = SmtpSetting.new
         end
         @mandrill_setting = MandrillSetting.first
         if !@mandrill_setting.present?
           @mandrill_setting = MandrillSetting.new
         end

         if params.present?
           @listloaded = params[:listloaded]
           @api_key = params[:api_key]
         end
      else
        if params[:listloaded].present?
          puts"========================params===================================="
          @listloaded = params[:listloaded]
          @api_key = params[:api_key]
          @apisetting.update_attributes(:api_key => @api_key, :list=>nil)
        end
        redirect_to edit_apisetting_path(@apisetting)
      end
   else
     flash[:error] = "Please Login First."
       redirect_to new_user_session_path
   end
end

  def load_list
    puts "============ load list ==================="
  if current_user && current_user.user_type=="admin"
    @api_key = params[:key]
    gb = Gibbon::API.new(@api_key)
    Gibbon::API.api_key = @api_key
    Gibbon::API.timeout = 15
    Gibbon::API.throws_exceptions = false

    # ------------load lists--------------

    @lists = Gibbon::API.lists.list
      if @lists["status"] == "error"
        puts "error"
        flash[:error]="Sorry! Please Enter Correct Api Key."
        redirect_to new_apisetting_path({:api_key => @api_key})
      else
        puts "seccess"
        @listloaded = []
        @lists['data'].each_with_index do |list, index|
          @listloaded[index] = {}
          @listloaded[index]["id"] = list["id"]
          @listloaded[index]["name"] = list["name"]

        end
        redirect_to new_apisetting_path({:listloaded => @listloaded, :api_key => @api_key})
      end
  else
    flash[:error] = "Please Login First."
    redirect_to new_user_session_path
  end
end


  def create
    if params[:apisetting][:api_key].present?
      @api_key = params[:apisetting][:api_key]
      gb = Gibbon::API.new(@api_key)
      Gibbon::API.api_key = @api_key
      Gibbon::API.timeout = 15
      Gibbon::API.throws_exceptions = false

      # ------------load lists--------------

      @lists = Gibbon::API.lists.list
      if @lists["status"] != "error"
              @apisetting = Apisetting.first
              if @apisetting.present?
                @apisetting.update_attributes!(params[:apisetting])
                redirect_to new_apisetting_path, :notice=>"Mandrill Api Key Successfully Created."
              else
                @apisetting = Apisetting.new(params[:apisetting])
                @apisetting.save!
                redirect_to new_apisetting_path, :notice=>"Mandrill Api Key Successfully Updated."
              end
      else
        flash[:error]= "Your Api key Is Invalid."
        redirect_to :back
      end
    else
      flash[:error]= "Please Enter Mailchimp Api Key."
      redirect_to :back
    end
  end


    def edit
     if current_user && current_user.user_type=="admin"
          @apisetting = Apisetting.find(params[:id])
          @api_key = @apisetting.api_key
          @list = @apisetting.list
          @key_mandrill = KeyMandrill.first
          if !@key_mandrill.present?
            @key_mandrill = KeyMandrill.new
          end

          @smtp_setting = SmtpSetting.first
          if !@smtp_setting.present?
            @smtp_setting = SmtpSetting.new
          end

          @mandrill_setting = MandrillSetting.first
          if !@mandrill_setting.present?
            @mandrill_setting = MandrillSetting.new
          end

          gb = Gibbon::API.new(@api_key)
          Gibbon::API.api_key = @api_key
          Gibbon::API.timeout = 15
          Gibbon::API.throws_exceptions = false

          # ------------load lists------------------------------------------------

          @lists = Gibbon::API.lists.list
          @listloaded = []
          if @lists.present?
          @lists['data'].each_with_index do |list, index|
            @listloaded[index] = {}
            @listloaded[index]["id"] = list["id"]
            @listloaded[index]["name"] = list["name"]
            if  @list ==  list["id"]
              @list_name = list["name"]
            end
           end
          end

          #=============================== mandriil template list ========================================
          if @key_mandrill && @key_mandrill.key.present?
              #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
              m = Mandrill::API.new(@key_mandrill.key)

              #@key = 'OCnumMSfJOSYVTFonjBOoQ'
              if defined?(m.templates.list.class)
                result = m.templates.list
                @list_template = []
                result.each_with_index do |template,index|
                  @list_template << template["name"]
                end
              else
                KeyMandrill.first.destroy
                puts "==========================mandrill key destroy======================================="
                flash[:error]="Your Api key is invalid"
                redirect_to :back
              end


          end
     else
       flash[:error] = "Please Login First."
       redirect_to new_user_session_path
     end
  end


  def update
    @apisetting = Apisetting.find(params[:id])
    if @apisetting.update_attributes(params[:apisetting])
      puts"===========================update========================================"
      redirect_to  new_apisetting_path, :notice=>"Mailchimp Api Key Successfully Created."
    else
      render :back, :error=>"Error Occur."
    end
  end

  def load_template
    if current_user && current_user.user_type=="admin"

       @key = params[:key]
      # ------------load lists--------------
      if @key.present?

        #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
        m = Mandrill::API.new(@key)
        #@key = 'OCnumMSfJOSYVTFonjBOoQ'
        if defined?(m.templates.list.class)
          @mandrill_key = KeyMandrill.first
          @mandrill_key.key = @key
          @mandrill_key.save!
            result = m.templates.list
            @list_template = []
            result.each_with_index do |template,index|
              @list_template << template["name"]
            end
            redirect_to new_apisetting_path
        else
          flash[:error] = "Please Enter Correct Api Key."
            redirect_to :back
        end
      else
         flash[:error] = "Please Enter Api Key."
          redirect_to :back
      end
    else
      flash[:error] = "Please Login First."
      redirect_to new_user_session_path
    end
  end


end
