task :Reminders =>:environment do
    puts "EVENT =========="

    @date = DateTime.now
    @date = @date-3
    #@date = DateTime.parse(@date)
    @upload_csvs = UploadCsv.where(:follow_up=>"Y")
    @key = KeyMandrill.first
        if @upload_csvs && @upload_csvs.first.present?

            @upload_csvs.each do |upload|
              #//puts upload.last_send_date
              #puts DateTime.parse(upload.last_send_date)   DateTime.strptime(a, "%m-%d-%y").to_time
              if upload.last_send_date && upload.last_send_date != '' && DateTime.strptime(upload.last_send_date, "%m-%d-%y").to_time <= @date
                puts"=================================================sdfdsfsdf======================================================"
                      @url =  upload.csv.csv_url
                      #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
                      m = Mandrill::API.new(@key.key)

                      #m = Mandrill::API.new 'OCnumMSfJOSYVTFonjBOoQ'
                      #m.templates.render 'ableform-notifications', [{:name => 'main', :content => 'The main content block'}]
                      #email_text =  "http://cross-channel-app.herokuapp.com#{@url}"
                      email_text =  "http://cross-channel-app.herokuapp.com/csvs/#{upload.csv.id}"
                      email_html = "<a href=#{email_text}>Please review the file here.</a>"


                      rendered = m.templates.render "Second Issue Notification From Align Technology", [
                                                                        {:name => "content_chimpchamp", :content => email_html}
                                                                    ]
                      puts rendered['html'] # print out the rendered HTML

                      #email_text =  "user_mailer/billing_warnint"
                      #email_html = render 'user_mailer/billing_warning'

                      @mandrill_setting = MandrillSetting.first
                      if @mandrill_setting && @mandrill_setting.subject.present?
                        message = {
                            :merge_vars=> [
                                {
                                    :rcpt=> upload.email,
                                    :vars=> [
                                        {:name=> "ORDERID",   :content=> upload.order_id},
                                        {:name=> "ISSUEASSET",:content=> upload.issue_asset},
                                        {:name=> "TICKETID",  :content=> upload.tickect_id}
                                    ]
                                }
                            ],

                            :subject=> @mandrill_setting.subject,
                            :from_name=> @mandrill_setting.user_name,
                            :text=> email_text,
                            :text=> rendered['html'],
                            :to=>[
                                {
                                    :email=> upload.email,
                                    :name =>  upload.patient_name
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
                                    :rcpt=> upload.email,
                                    :vars=> [
                                        {:name=> "ORDERID",   :content=> upload.order_id},
                                        {:name=> "ISSUEASSET",:content=> upload.issue_asset},
                                        {:name=> "TICKETID",  :content=> upload.tickect_id}
                                    ]
                                }
                            ],
                            :subject=> "Channel Sync",
                            :from_name=> "ChimpChamp",
                            :text=> email_text,
                            :text=> rendered['html'],
                            :to=>[
                                {
                                    :email=> upload.email,
                                    :name =>  upload.patient_name
                                }
                            ],
                            :html=>email_html,
                            :html=>rendered['html'],
                            :from_email=>'admin@chimpchamp.com'
                        }
                      end
                      sending = m.messages.send message
                      if sending[0]["status"] == "sent"
                        #upload.update_attributes(:message_sent => upload.message_sent+1, :last_send_date => DateTime.now.strftime("%m-%d-%y"), :last_message_name=> "Second Issue Notification From Align Technology")
                        upload.update_attributes(:message_sent => upload.message_sent+1, :last_send_date => Time.now.strftime("%m-%d-%y"), :last_message_name=> "Second Issue Notification From Align Technology")

                      end
                end
            end

        else
        puts  "===================================No CSVs Uploaded========================================="
        end

    puts "========================================    End CALLS  ===================================================================="




end
