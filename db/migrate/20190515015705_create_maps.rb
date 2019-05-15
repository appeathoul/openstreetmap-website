class CreateMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :maps do |t|
      t.column "name",        	:string, :limit => 255
      t.column "url", 		:string, :limit => 255
      t.column "order", 	     	:bigint, :null => false
      t.column "default",         :boolean, :null => false
    end
  end
end
