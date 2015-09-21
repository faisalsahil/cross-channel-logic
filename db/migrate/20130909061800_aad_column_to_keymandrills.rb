class AadColumnToKeymandrills < ActiveRecord::Migration
  def change
    add_column :key_mandrills, :template_name, :string
  end
end
