class CreateMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :maps do |t|
      t.column "code",        	:string, :limit => 255
      t.column "name",        	:string, :limit => 255
      t.column "itype", 		  :string, :limit => 50
      t.column "template", 	  :string, :limit => 255
      t.column "projection", 	  :string,:default => "EPSG:4326"
      t.column "startDate",   :datetime
      t.column "endDate",     :datetime
      t.column "zoom_extent", 		:string, :limit => 50
      t.column "terms_url", 		:string, :limit => 255
      t.column "terms_text", 		:string, :limit => 255
      t.column "overzoom",        :boolean, :null => false
      t.column "default",        :boolean, :null => false
      t.column "description",  :text, :default => "", :null => false
      t.column "icon", 		      :string, :limit => 255
      t.column "overlay",         :boolean, :null => false
      t.column "order", 	     	:bigint, :null => false
      t.column "polygon", 	    :text, :default => "", :null => false
    end
  end
end
