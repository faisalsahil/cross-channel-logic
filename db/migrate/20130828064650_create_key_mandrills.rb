class CreateKeyMandrills < ActiveRecord::Migration
  def change
    create_table :key_mandrills do |t|
      t.string :key

      t.timestamps
    end
  end
end
