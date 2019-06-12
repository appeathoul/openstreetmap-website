class AddColumnKey < ActiveRecord::Migration[5.2]
  def change
    add_column :layers, :key, :string
  end
end
