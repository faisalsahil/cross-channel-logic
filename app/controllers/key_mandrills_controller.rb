class KeyMandrillsController < ApplicationController

 def index

 end
  def create
    if params[:key_mandrill][:key].present?
      @key = params[:key_mandrill][:key]
      @key_mandrill = KeyMandrill.new(params[:key_mandrill])

      m = Mandrill::API.new(@key)

      #@key = 'OCnumMSfJOSYVTFonjBOoQ'
      if defined?(m.templates.list.class)
        @key_mandrill.save!
        redirect_to  new_apisetting_path, :notice=>"Mandrill Api Key Successfully Created."
      else
        flash[:error]="Your Api Key Is Invalid."
        redirect_to :back
      end
    else
      flash[:error]="Please Enter Mandrill Api Key."
      redirect_to :back
    end
  end

  def new
    @key_mandrill = KeyMandrill.new
  end

  def update
    @key_mandrill = KeyMandrill.find(params[:id])
    @key_mandrill.update_attributes(params[:key_mandrill])
    redirect_to  new_apisetting_path, :notice=>"Mandrill Api Key Successfully Updated."
  end

end
