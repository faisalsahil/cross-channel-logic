class UploadCsv < ActiveRecord::Base
  attr_accessible  :mclist_id, :date_added,:follow_up,:clicked_link_date,  :pdf_url,:message_sent,:last_message_name,:last_send_date,:remove_date,
                   :remove_user,:order_id,:patient_name, :tickect_id,:created_on,
                   :issue_asset,:image_number,:email,:office_number,:doctor_name, :list_id,:list_name, :approved_date, :approved
   has_one :csv


end
