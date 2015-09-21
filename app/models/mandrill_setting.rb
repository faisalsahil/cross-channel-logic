class MandrillSetting < ActiveRecord::Base
  attr_accessible :from_email, :subject, :from_name

  validates :from_email, :presence => true
  validates :subject, :presence => true
  validates :from_name, :presence => true
end
