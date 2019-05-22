# == Schema Information
#
# Table name: layer_tags
#
#  layer_id       :bigint(8)        not null, primary key
#  key            :string(100)      not null, primary key
#  name           :string(255)
#  required       :boolean          default(FALSE), not null
#  optional_value :string(255)
#

class LayerTag < ActiveRecord::Base
    self.primary_keys = "layer_id", "key"

    belongs_to :layer

    validates :layer_id, :presence => true, :allow_nil => false
    validates :key, :presence => true
    validates :name, :presence => true
    validates :required, :presence => false

    ##
    # 转化为XML字符串
    def to_xml_node
        el = XML::Node.new "tag"
        
        el["layer_id"] = layer_id.to_s
        el["name"] = name.to_s
        el["key"] = key.to_s
        el["required"] = required.to_s
        el["optional_value"] = optional_value.to_s
    
        el
    end
end
