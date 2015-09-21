class Csv < ActiveRecord::Base
  attr_accessible :csv ,:upload_csv_id, :csv_url, :list_id
  belongs_to :upload_csv

  mount_uploader :csv, PdfUploader

  def self.import(file, id, error_arr)

    @apisetting = Apisetting.first
    #@list = @apisetting.list
    @api_key = @apisetting.api_key
    @date = DateTime.now.to_date
    @date = @date.strftime("%m-%d-%Y")

    gb = Gibbon::API.new(@api_key)
    Gibbon::API.api_key = @api_key
    Gibbon::API.timeout = 15
    Gibbon::API.throws_exceptions = false

        #  =================================    Getting List ========================================== #

        @lists = Gibbon::API.lists.list
        @listloaded = []
        @lists['data'].each_with_index do |list, index|
          @listloaded[index] = {}
          if id ==  list["id"]
            @list_name = list["name"]
          end
        end
    # ===========================================   Subscribe csv to mail chimp ================================ #

    CSV.foreach(file.path, :headers=> true) do |row|
      if row.present?
        flag = Gibbon::API.lists.subscribe({:api_key=>@api_key,:id => id,
                                            :email => {:email => row[7]}, :double_optin => false, :update_existing => true,
                                            :replace_interests =>true , :send_welcome => false
                                           })
            if !defined?(flag.status)
               UploadCsv.create!(:list_id=>id,:list_name=>@list_name,:date_added => @date,:mclist_id => id,:follow_up=>"Y",:clicked_link_date=> 0 ,:doctor_name => row[0],:order_id => row[1],:patient_name => row[2],:tickect_id => row[3],:created_on => row[4],:issue_asset => row[5],:image_number => row[6],:email => row[7],:office_number => row[8])
            else
               error_arr << flag
            end
      end
    end
  end
end
