class AddDoctorNameToUploadcsvs < ActiveRecord::Migration
  def change
    add_column :upload_csvs, :doctor_name, :string

  end
end
