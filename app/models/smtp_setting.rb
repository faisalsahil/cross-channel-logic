class SmtpSetting < ActiveRecord::Base
  attr_accessible :address, :authentication, :domain, :enable_starttls_auto, :password, :port, :user_name

  validates :address, :presence => true
  validates :authentication, :presence => true
  validates :domain, :presence => true
  validates :enable_starttls_auto, :presence => true
  validates :password, :presence => true
  validates :port, :presence => true
  validates :user_name, :presence => true
end
