# == Schema Information
#
# Table name: depts
#
#  id        :bigint(8)        not null, primary key
#  name      :string(255)
#  parent_id :bigint(8)        not null
#  order     :bigint(8)        not null
#  sign      :string(50)
#

class Dept < ActiveRecord::Base
    self.primary_key = "id"
    
    ##
    # 转化为XML字符串
    def to_xml_node
        el = XML::Node.new "dept"
        
        el["id"] = id.to_s
        el["name"] = name.to_s
        el["parent_id"] = parent_id.to_s
        el["order"] = order.to_s
        el["sign"] = sign.to_s
    
        el
    end
    
end
