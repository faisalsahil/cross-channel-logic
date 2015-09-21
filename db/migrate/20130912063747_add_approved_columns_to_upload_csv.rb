class AddApprovedColumnsToUploadCsv < ActiveRecord::Migration
  def change
    add_column :upload_csvs, :approved, :string, :default=>nil
    add_column :upload_csvs, :approved_date, :string, :default=>nil
  end
end
