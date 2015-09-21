class ChangeColumnFromSmtpSettings < ActiveRecord::Migration
  def change
    remove_column :smtp_settings, :enable_starttls_auto
    add_column :smtp_settings, :enable_starttls_auto, :boolean, :default=>true
  end
end
