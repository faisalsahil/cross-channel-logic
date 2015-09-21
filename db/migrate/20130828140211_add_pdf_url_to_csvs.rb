class AddPdfUrlToCsvs < ActiveRecord::Migration
  def change
    add_column :csvs, :csv_url,:string
  end
end
