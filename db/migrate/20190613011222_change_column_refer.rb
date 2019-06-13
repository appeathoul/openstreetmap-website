class ChangeColumnRefer < ActiveRecord::Migration[5.2]
  def change
    change_column :layers, :refer, :string
  end
end
