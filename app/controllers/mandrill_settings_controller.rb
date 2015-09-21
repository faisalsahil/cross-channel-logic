class MandrillSettingsController < ApplicationController

  def create

    @mandrill_setting = MandrillSetting.new(params[:mandrill_setting])
    if @mandrill_setting.save
    redirect_to new_apisetting_path, :notice => "Successfully Created."
    else
      flash[:error]="Please Fill all Fields."
      redirect_to :back
    end
  end

  def update
    @mandrill_setting = MandrillSetting.find(params[:id])
    @mandrill_setting.update_attributes(params[:mandrill_setting])
    redirect_to  new_apisetting_path, :notice=>"Mandrill Settings Successfully Updated."
  end
end
