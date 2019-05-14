class CreateDepts < ActiveRecord::Migration[5.2]
  def change
    create_table :depts do |t|
      t.column "name",        	:string, :limit => 255
      t.column "parent_id", 	:bigint, :null => false
      t.column "order", 	     	:bigint, :null => false
      t.column "sign",          	:string, :limit => 50
    end
  end
end
