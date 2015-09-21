class AddTepToCsvs < ActiveRecord::Migration
  def change
    add_column :csvs, :tem, :integer
  end
end
