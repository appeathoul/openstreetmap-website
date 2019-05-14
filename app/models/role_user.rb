# == Schema Information
#
# Table name: role_users
#
#  id      :bigint(8)        not null, primary key
#  user_id :bigint(8)        not null
#  role_id :bigint(8)        not null
#

class RoleUser < ActiveRecord::Base

    self.primary_keys = "id"

    # ##
    # # 转化为XML字符串
    # def to_xml_node
    #     el = XML::Node.new "sys_role"
        
    #     el["id"] = id.to_s
    #     el["user_id"] = name.to_s
    #     el["role_id"] = order.to_s
    
    #     el
    # end
end
