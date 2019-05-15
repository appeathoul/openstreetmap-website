# == Schema Information
#
# Table name: dept_users
#
#  id      :bigint(8)        not null, primary key
#  user_id :bigint(8)        not null
#  dept_id :bigint(8)        not null
#

class DeptUser < ActiveRecord::Base
    self.primary_keys = "id"
end
