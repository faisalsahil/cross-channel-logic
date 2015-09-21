class AddColumnToCsvs < ActiveRecord::Migration
  def change
    add_column :csvs, :upload_csvs_id,:integer
  end
end
