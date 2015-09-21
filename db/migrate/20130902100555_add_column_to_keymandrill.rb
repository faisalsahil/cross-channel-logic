class AddColumnToKeymandrill < ActiveRecord::Migration
  def change
    add_column :key_mandrills, :list, :string
  end
end
