# == Schema Information
#
# Table name: template_layers
#
#  id       :bigint(8)        not null, primary key
#  tmpl_id  :bigint(8)        not null
#  layer_id :bigint(8)        not null
#  status   :string(10)
#

class TemplateLayer < ActiveRecord::Base
    self.primary_key = "id"

    belongs_to :template

    # def to_xml_node
    #     el1 = XML::Node.new "tm"
    #     el1["k"] = k
    #     el1["v"] = v
    
    #     el1
    #   end
    
end
