# == Schema Information
#
# Table name: layers
#
#  id          :bigint(8)        not null, primary key
#  name        :string(255)
#  geotype     :string(10)
#  itype       :string(10)
#  order       :bigint(8)        not null
#  icon        :string(255)
#  sign        :string(50)
#  region_code :string(50)
#  refer       :bigint(8)
#  condition   :string
#  editlevel   :bigint(8)
#

class Layer  < ActiveRecord::Base
    self.primary_key = "id"

    has_many :tags, :class_name => "LayerTag",  :foreign_key => :layer_id
    
    ##
    # 转化为XML字符串
    def to_xml_node
        el = XML::Node.new "layer"
        
        el["id"] = id.to_s
        el["name"] = name.to_s
        el["type"] = itype.to_s
        el["geotype"] = geotype.to_s
        el["order"] = order.to_s
        el["sign"] = sign.to_s
        el["icon"] = icon.to_s
        el["region_code"] = region_code.to_s
        el["refer"] = refer.to_s
        el["condition"] = condition.to_s
        el["editlevel"] = editlevel.to_s

        el
    end
end
