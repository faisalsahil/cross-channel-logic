class CreateManages < ActiveRecord::Migration
  def change
    create_table :manages do |t|
      t.string :email
      t.string :tickeck_id

      t.timestamps
    end
  end
end
