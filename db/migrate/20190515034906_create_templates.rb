class CreateTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :templates do |t|
      t.column "name",        :string, :limit => 255
      t.column "itype", 		  :string, :limit => 50
      t.column "sign", 		    :string, :limit => 50
      t.column "status", 		  :string, :limit => 10
    end
  end
end
