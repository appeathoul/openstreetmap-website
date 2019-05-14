class CreateSysRole < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_roles do |t|
      t.column "name",        :string, :limit => 255
      t.column "type",          :string, :limit => 50
      t.column :order, 	      :bigint, :null => false
      t.column "sign",          :string, :limit => 50
    end
  end
end
