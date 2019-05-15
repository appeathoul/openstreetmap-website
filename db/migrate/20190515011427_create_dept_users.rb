class CreateDeptUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :dept_users do |t|
      t.column :user_id, 	      :bigint, :null => false
      t.column "dept_id",       :bigint, :null => false
    end
  end
end
