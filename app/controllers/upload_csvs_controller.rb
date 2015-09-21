class UploadCsvsController < ApplicationController
  def index
   if current_user && current_user.user_type == "admin"
      #@upload_csvs = UploadCsv.all
      @upload_csvs = UploadCsv.where(:message_sent=>0)
      if  @upload_csvs.first.present?
              @key_mandrill = KeyMandrill.first
              @csv  = Csv.new
              #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
              if @key_mandrill.present?
                      m = Mandrill::API.new(@key_mandrill.key)
                      if  defined?(m.templates.list.class)
                           result = m.templates.list
                           @list_template = []
                          result.each_with_index do |template,index|
                          @list_template << template["name"]
                          end
                      else
                        redirect_to :back,:notice=>"Please Enter Mandrill Api Key First."
                      end
              else
                flash[:error]= "Please go to Setting Section and Set Mandrill Api Key First."
                redirect_to :back
              end
      else
        redirect_to :root , :notice=>"No Record Found. Please Subscribe First."
        #redirect_to :back, :notice=>"No record found. Please subscribe first"
      end
   else
     flash[:error] = "Please Login First."
      redirect_to new_user_session_path
   end
 end

  def new
    if current_user && current_user.user_type == "admin"
      @csv = Csv.new
      @upload_csv= UploadCsv.find_by_id(params[:upload_csv_id])
      puts
    else
      flash[:error] = "Please Login First."
      redirect_to new_user_session_path
    end
  end

  def destroy
    @action = UploadCsv.find(params[:id])
    @action.destroy
    redirect_to :back
  end

  # GET /integrations/1/edit
  def edit
    @action = UploadCsv.find(params[:id])
  end

  def update
    @action = UploadCsv.find(params[:id])
    if @action.update_attributes(params[:upload_csv])
      redirect_to upload_csvs_path,:notice=>"Successfully Updated."
    else
      redirect_to upload_csvs_path,:notice=>"Record Not Found."
    end
  end





  def send_email
    if current_user && current_user.user_type == "admin"

      @list_name = params[:key] || ""
      if @list_name.present?
        @key = KeyMandrill.first
        if !@key.present?
          redirect_to new_apisetting_path, :notice=>"Please Enter Mandrill Key Here First."
        else
          m = Mandrill::API.new(@key.key)

          #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
          if defined?(m.templates.list.class)
            #@csvs = Csv.joins(:upload_csv).where("upload_csv_id IS NOT NULL AND upload_csvs.message_sent = 0 OR  upload_csvs.message_sent = '0'").includes(:upload_csv)
            #@csvs = Csv.joins(:upload_csv).where("upload_csv_id IS NOT NULL AND upload_csvs.message_sent = 0 AND upload_csvs.follow_up IS NOT 'N' ").includes(:upload_csv)
            @csvs = Csv.joins(:upload_csv).where("upload_csv_id IS NOT NULL AND upload_csvs.message_sent = 0").includes(:upload_csv)
            if @csvs && @csvs.first.present?
            @csvs.each do |csv|
              @url =  csv.csv_url
              @upload_csv = csv.upload_csv
              puts "====================================Sending emails================================================================="
              #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
              email_text =  "http://cross-channel-app.herokuapp.com/csvs/#{csv.id}"
              email_html = "<a href=#{email_text}>Please review the file here.</a>"

              #==================== Approved Link =============================================
              email_text1 =  "http://cross-channel-app.herokuapp.com/csvs/#{csv.id}/approved?approved=" + '1'
              email_html1 = "<a href=#{email_text1}>2.Proceed with the case as is (doctor assumes responsibility for any fitting issue)</a>"

              #========================== Cancel Link =====================================================
              email_text0 =  "http://cross-channel-app.herokuapp.com/csvs/#{csv.id}/approved?approved=" + '0'
              email_html0 = "<a href=#{email_text0}>1.Cancel the case and rescan the patient</a>"


              rendered = m.templates.render "#{@list_name}", [
                                                              {:name => "content_chimpchamp", :content => email_html},
                                                              {:name => "accepttracking", :content => email_html1},
                                                              {:name => "canceltracking", :content => email_html0},
                                                            ]
              @mandrill_setting = MandrillSetting.first
              if @mandrill_setting && @mandrill_setting.subject.present?
                message = {
                    :merge_vars=> [
                        {
                            :rcpt=> @upload_csv.email,
                            :vars=> [
                                {:name=> "ORDERID",   :content=> @upload_csv.order_id},
                                {:name=> "ISSUEASSET",:content=> @upload_csv.issue_asset},
                                {:name=> "TICKETID",  :content=> @upload_csv.tickect_id}
                            ]
                        }
                    ],

                    :subject=> @mandrill_setting.subject,
                    :from_name=> @mandrill_setting.user_name,
                    :text=> email_text,
                    :text=> rendered['html'],
                    :to=>[
                        {
                            :email=> @upload_csv.email,
                            :name =>  @upload_csv.patient_name
                        }
                    ],
                    :html=>email_html,
                    :html=>rendered['html'],
                    :from_email=> @mandrill_setting.email
                }
              else
                message = {
                    :merge_vars=> [
                        {
                            :rcpt=> @upload_csv.email,
                            :vars=> [
                                {:name=> "ORDERID",   :content=> @upload_csv.order_id},
                                {:name=> "ISSUEASSET",:content=> @upload_csv.issue_asset},
                                {:name=> "TICKETID",  :content=> @upload_csv.tickect_id}
                            ]
                        }
                    ],
                    :subject=> "Channel Sync",
                    :from_name=> "ChimpChamp",
                    :text=> email_text,
                    :text=> rendered['html'],
                    :to=>[
                        {
                            :email=> @upload_csv.email,
                            :name =>  @upload_csv.patient_name
                        }
                    ],
                    :html=>email_html,
                    :html=>rendered['html'],
                    :from_email=>'admin@chimpchamp.com'
                }
              end

              sending = m.messages.send message

              if sending[0]["status"] == "sent"
                #@upload_csv.update_attributes(:message_sent => @upload_csv.message_sent+1, :last_send_date => Time.now.strftime("%m-%d-%y"), :last_message_name=> @list_name)
                @upload_csv.update_attributes(:message_sent => @upload_csv.message_sent+1, :last_send_date => Time.now.strftime("%m-%d-%y"), :last_message_name=> @list_name)
              end
            end
            else
              redirect_to :back, :notice=>"Please Enter Correct Mandrill Api Key First."
            end
            redirect_to :back, :notice=>"Emails were Sent to the Users having their PDFs Uploaded!!"
          else
            redirect_to :back, :notice=>"Please Enter Correct Mandrill Api Key First."
          end
        end
      else
        redirect_to :back, :notice=>"Please Select Template."
      end
    else
      flash[:error] = "Please Login First."
      redirect_to new_user_session_path
    end

  end


  #def scheduled_tasks
  #  @date = DateTime.now.to_date
  #  @date = @date-3
  #  @date = @date.strftime("%m-%d-%Y")
  #  @upload_csvs = UploadCsv.where(:follow_up=>"Y", :last_send_date=> @date)
  #
  #  puts "===================================================================================================================================="
  #  puts "scheduled tasks called"
  #  @key = KeyMandrill.first
  #  @upload_csvs.each do |upload|
  #    @url =  upload.csv_url
  #    #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
  #    m = Mandrill::API.new(@key)
  #
  #    #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
  #    #m.templates.render 'ableform-notifications', [{:name => 'main', :content => 'The main content block'}]
  #    #email_text =  "http://cross-channel-app.herokuapp.com#{@url}"
  #    email_text =  "http://cross-channel-app.herokuapp.com/csvs/#{upload.csv.id}"
  #    email_html = "<a href=#{email_text}>Please review the file here.</a>"
  #
  #
  #    rendered = m.templates.render "ableform-notification", [{:name => "content_chimpchamp", :content => email_html}]
  #    puts rendered['html'] # print out the rendered HTML
  #
  #    #email_text =  "user_mailer/billing_warnint"
  #    #email_html = render 'user_mailer/billing_warning'
  #
  #    @mandrill_setting = MandrillSetting.first
  #    if @mandrill_setting && @mandrill_setting.subject.present?
  #      message = {
  #          :subject=> @mandrill_setting.subject,
  #          :from_name=> @mandrill_setting.user_name,
  #          :text=> email_text,
  #          :text=> rendered['html'],
  #          :to=>[
  #              {
  #                  :email=> @upload_csv.email,
  #                  :name =>  "ChimpChamp"
  #              }
  #          ],
  #          :html=>rendered['html'],
  #          :from_email=> @mandrill_setting.email
  #      }
  #    else
  #      message = {
  #          :subject=> "Cross Channel",
  #          :from_name=> "ChimpChamp",
  #          :text=> email_text,
  #          :to=>[
  #              {
  #                  :email=> @upload_csv.email,
  #                  :name =>  "ChimpChamp"
  #              }
  #          ],
  #          :html=>rendered['html'],
  #          :from_email=>'zaeem@chimpchamp.com'
  #      }
  #    end
  #    sending = m.messages.send message
  #  end
  #end




  #def send_email
  #  if current_user && current_user.user_type == "admin"
  #
  #    @list_name = params[:key] || ""
  #    if @list_name.present?
  #      @key = KeyMandrill.first
  #      if !@key.present?
  #        redirect_to new_apisetting_path, :notice=>"Please enter mandrill key here first."
  #      else
  #        m = Mandrill::API.new(@key.key)
  #
  #        #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
  #        if defined?(m.templates.list.class)
  #          #@csvs = Csv.joins(:upload_csv).where("upload_csv_id IS NOT NULL AND upload_csvs.message_sent = 0 OR  upload_csvs.message_sent = '0'").includes(:upload_csv)
  #          #@csvs = Csv.joins(:upload_csv).where("upload_csv_id IS NOT NULL AND upload_csvs.message_sent = 0 AND upload_csvs.follow_up IS NOT 'N' ").includes(:upload_csv)
  #          @csvs = Csv.joins(:upload_csv).where("upload_csv_id IS NOT NULL AND upload_csvs.message_sent = 0").includes(:upload_csv)
  #          @csvs.each do |csv|
  #            @url =  csv.csv_url
  #            @upload_csv = csv.upload_csv
  #            puts "====================================================================================================="
  #            #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
  #            email_text =  "http://cross-channel-app.herokuapp.com/csvs/#{csv.id}"
  #            email_html = "<a href=#{email_text}>Please review the file here.</a>"
  #
  #            #==================== Approved Link =============================================
  #            #email_text1 =  "http://cross-channel-app.herokuapp.com/csvs/#{csv.id}/approved?approved=" + 1
  #            #email_html1 = "<a href=#{email_text1}>Click here for approval.</a>"
  #
  #            #========================== Cancel Link =====================================================
  #            #email_text0 =  "http://cross-channel-app.herokuapp.com/csvs/#{csv.id}/approved?approved=" + 0
  #            #email_html0 = "<a href=#{email_text0}>Click here to cancel.</a>"
  #
  #            #rendered = m.templates.render "#{@list_name}", [
  #            #    {:name => "content_chimpchamp", :content => email_html}]
  #
  #
  #            rendered = m.templates.render "#{@list_name}", [{:name => "std_content00", :content => email_html}]
  #
  #            @mandrill_setting = MandrillSetting.first
  #            if @mandrill_setting && @mandrill_setting.subject.present?
  #              message = {
  #                  :subject=> @mandrill_setting.subject,
  #                  :from_name=> @mandrill_setting.user_name,
  #                  :text=> email_text,
  #                  :to=>[
  #                      {
  #
  #                          :email=> @upload_csv.email,
  #                          :name =>  "zaeem"
  #                      }
  #                  ],
  #                  :html=>rendered['html'],
  #                  :from_email=>'zaeem@chimpchamp.com'
  #
  #              }
  #            else
  #              message = {
  #                  :subject=> "Cross Channel",
  #                  :from_name=> "ChimpChamp",
  #                  :text=> email_text,
  #                  :to=>[
  #                      {
  #                          :email=> @upload_csv.email,
  #                          :name =>  "zaeem"
  #                      }
  #                  ],
  #                  :html=>rendered['html'],
  #                  :from_email=>'zaeem@chimpchamp.com'
  #
  #              }
  #            end
  #
  #            sending = m.messages.send message
  #
  #            if sending[0]["status"] == "sent"
  #              @upload_csv.update_attributes(:message_sent => @upload_csv.message_sent+1, :last_send_date => Time.now.strftime("%m-%d-%y"), :last_message_name=> @list_name)
  #              #@date = DateTime.now.to_date
  #              #@date = @date.strftime("%m-%d-%Y")
  #              #@upload_csv.message_sent = 1
  #              #@upload_csv.last_send_date = @date
  #              #@upload_csv.last_message_name = @list_name
  #
  #              #@upload_csv.follow_up = "N"
  #              #@upload_csv.save!
  #            end
  #          end
  #          redirect_to :back, :notice=>"Emails were sent to the users having their Pdfs uploaded!!"
  #        else
  #          redirect_to :back, :notice=>"Please enter correct Mandrill Api key first"
  #        end
  #      end
  #    else
  #      redirect_to :back, :notice=>"Please select template"
  #    end
  #  else
  #    redirect_to new_user_session_path,:notice=>"Please login first"
  #  end
  #
  #end


end

