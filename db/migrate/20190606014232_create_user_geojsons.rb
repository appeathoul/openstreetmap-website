class CreateUserGeojsons < ActiveRecord::Migration[5.2]
  def change
    create_table :user_geojsons do |t|
      t.column "user_id", 	     	:bigint, :null => false
      t.column "template_id", 		:bigint, :null => false
      t.column "geojson", 		:text
    end
  end
end
