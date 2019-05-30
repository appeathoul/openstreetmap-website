class AddColumnCondition < ActiveRecord::Migration[5.2]
  def change
    add_column :layers, :condition, :string
    add_column :layers, :editlevel, :bigint
  end
end
