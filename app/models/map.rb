# == Schema Information
#
# Table name: maps
#
#  id          :bigint(8)        not null, primary key
#  code        :string(255)
#  name        :string(255)
#  itype       :string(50)
#  template    :string(255)
#  projection  :string           default("EPSG:4326")
#  startDate   :datetime
#  endDate     :datetime
#  zoom_extent :string(50)
#  terms_url   :string(255)
#  terms_text  :string(255)
#  overzoom    :boolean          not null
#  default     :boolean          not null
#  description :text             default(""), not null
#  icon        :string(255)
#  overlay     :boolean          not null
#  order       :bigint(8)        not null
#  polygon     :text             default(""), not null
#

class Map < ActiveRecord::Base
    self.primary_key = "id"
    
    ##
    # 转化为XML字符串
    def to_xml_node
        el = XML::Node.new "map"
        
        el["uid"] = id.to_s
        el["id"] = code.to_s
        el["name"] = name.to_s
        el["type"] = itype.to_s
        el["template"] = template.to_s
        el["projection"] = projection.to_s
        el["startDate"] = startDate.to_s
        el["endDate"] = endDate.to_s
        el["zoomExtent"] = zoom_extent.to_s
        el["terms_url"] = terms_url.to_s
        el["terms_text"] = terms_text.to_s
        el["overzoom"] = overzoom.to_s
        el["default"] = default.to_s
        el["description"] = description.to_s
        el["icon"] = icon.to_s
        el["overlay"] = overlay.to_s
        el["order"] = order.to_s
        el["polygon"] = polygon.to_s
    
        el
    end
end
