class CreateMandrillSettings < ActiveRecord::Migration
  def change
    create_table :mandrill_settings do |t|
      t.string :subject
      t.string :user_name
      t.string :email

      t.timestamps
    end
  end
end
