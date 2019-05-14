# == Schema Information
#
# Table name: sys_roles
#
#  id    :bigint(8)        not null, primary key
#  name  :string(255)
#  order :bigint(8)        not null
#  sign  :string(50)
#

class SysRole < ActiveRecord::Base

    self.primary_key = "id"
    
    ##
    # 转化为XML字符串
    def to_xml_node
        el = XML::Node.new "sys_role"
        
        el["id"] = id.to_s
        el["name"] = name.to_s
        el["order"] = order.to_s
        el["sign"] = sign.to_s
    
        el
    end
end
