class AddUpToCsv < ActiveRecord::Migration
  def change
         remove_column :csvs, :upload_csvs_id
    add_column :csvs, :upload_csv_id,:integer
  end
end
