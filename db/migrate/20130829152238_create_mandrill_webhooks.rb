class CreateMandrillWebhooks < ActiveRecord::Migration
  def change
    create_table :mandrill_webhooks do |t|

      t.timestamps
    end
  end
end
