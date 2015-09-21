class ChangeTypeOfField < ActiveRecord::Migration
  def change
    remove_column :upload_csvs, :mclist_id
    add_column :upload_csvs, :mclist_id, :string
  end
end
