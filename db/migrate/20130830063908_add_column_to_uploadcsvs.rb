class AddColumnToUploadcsvs < ActiveRecord::Migration
  def change
    add_column :upload_csvs, :list_name,:string
    add_column :upload_csvs, :list_id,:string
    add_column :csvs, :list_id,:string
  end
end
