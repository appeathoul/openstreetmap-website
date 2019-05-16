# == Schema Information
#
# Table name: templates
#
#  id     :bigint(8)        not null, primary key
#  name   :string(255)
#  itype  :string(50)
#  sign   :string(50)
#  status :string(10)
#

class Template < ActiveRecord::Base

    self.primary_key = "id"

    has_many :layers, :class_name => "TemplateLayer",  :foreign_key => :tmpl_id
    
    ##
    # 转化为XML字符串
    def to_xml_node
        el = XML::Node.new "template"
        
        el["id"] = id.to_s
        el["name"] = name.to_s
        el["type"] = itype.to_s
        el["sign"] = sign.to_s
        el["status"] = status.to_s
    
        el
    end
end
