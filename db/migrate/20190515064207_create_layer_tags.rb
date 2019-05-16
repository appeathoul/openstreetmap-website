require "migrate"

class CreateLayerTags < ActiveRecord::Migration[5.2]
  def self.up
    create_table "layer_tags", :id => false do |t|
      t.column "layer_id", 		:bigint, :null => false
      t.column "key", 		:string, :limit => 100
      t.column "name", 		:string, :limit => 255
      t.column "required", 		:boolean, :null => false
      t.column "optional_value", 		:string, :limit => 255
    end

    add_primary_key "layer_tags", %w[layer_id key]
  end
end
