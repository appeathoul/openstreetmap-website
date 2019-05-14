class CreateRoleUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :role_users do |t|
      t.column :user_id, 	      :bigint, :null => false
      t.column :role_id,        :bigint, :null => false
    end
  end
end
