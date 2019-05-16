class CreateTemplateLayers < ActiveRecord::Migration[5.2]
  def change
    create_table :template_layers do |t|
      t.column "tmpl_id", 	     	:bigint, :null => false
      t.column "layer_id", 		:bigint, :null => false
      t.column "status", 		:string, :limit => 10
    end
  end
end
