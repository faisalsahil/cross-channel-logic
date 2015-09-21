class ChangeColumnFromMandrillsettings < ActiveRecord::Migration
  def change
      remove_column :mandrill_settings, :user_name
      remove_column :mandrill_settings, :email
    add_column :mandrill_settings , :from_email, :string
    add_column :mandrill_settings , :from_name, :string

  end
end
