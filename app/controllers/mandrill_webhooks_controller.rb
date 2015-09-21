class MandrillWebhooksController < ApplicationController

  def index
      #@date = DateTime.now.to_date
      #@date = @date.strftime("%m-%d-%Y")
      #render :json=> { :email => params[:email], :url => params[:url] }
      return render :json=> params.inspect
  end

  def new
    @action =  MandrillWebhook.new
  end
end


#  def request
#    @date = DateTime.now.to_date
#    @date = @date.strftime("%m-%d-%Y")
#
#     ##########################  parse json params here #####################################
#       #@email from params
#       #@url from params
#       @email = params["email"]
#       @url = params["url"]
#    #########################################################################################
#
#    @member = UploadCsv.find_by_email(@email)
#    @pdf_url = @member.csv.csv_url
#    if @member.email == @email && @pdf_url == @url
#      @member.update_attributes(follow_up: "N", clicked_link_date: @date )
#    end
  #end
