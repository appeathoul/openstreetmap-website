# == Schema Information
#
# Table name: maps
#
#  id      :bigint(8)        not null, primary key
#  name    :string(255)
#  url     :string(255)
#  order   :bigint(8)        not null
#  default :boolean          not null
#

class Map < ActiveRecord::Base
    self.primary_key = "id"
    
    ##
    # 转化为XML字符串
    def to_xml_node
        el = XML::Node.new "map"
        
        el["id"] = id.to_s
        el["name"] = name.to_s
        el["url"] = url.to_s
        el["order"] = order.to_s
        el["default"] = default.to_s
    
        el
    end
end
