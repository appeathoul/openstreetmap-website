class CreateLayers < ActiveRecord::Migration[5.2]
  def change
    create_table :layers do |t|
      t.column "name",        	:string, :limit => 255
      t.column "geotype", 		:string, :limit => 10
      t.column "itype", 		:string, :limit => 10
      t.column "order", 		:bigint, :null => false
      t.column "icon", 		:string, :limit => 255
      t.column "sign", 		:string, :limit => 50
      t.column "region_code", 		:string, :limit => 50
    end
  end
end
