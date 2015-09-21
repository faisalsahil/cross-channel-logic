class SmtpSettingsController < ApplicationController

  def create
        @smtp_setting = SmtpSetting.new(params[:smtp_setting])
      if @smtp_setting.save
        redirect_to new_apisetting_path, :notice => "Successfully Created."
    else
      flash[:error]="Please Fill all the Fields."
      redirect_to :back
    end
  end

  def update
    @smtp_setting = SmtpSetting.find(params[:id])
    @smtp_setting.update_attributes(params[:smtp_setting])
    redirect_to  new_apisetting_path, :notice=>"SMTP Settings Successfully Updated."
  end

end
