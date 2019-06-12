# == Schema Information
#
# Table name: user_geojsons
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)        not null
#  template_id :bigint(8)        not null
#  geojson     :text
#

class UserGeojson < ActiveRecord::Base
    
    belongs_to :user, :class_name => "User", :foreign_key => :user_id

    def self.getjson(user)
        @jsonobj = UserGeojson.where(:user_id => user.id).first
        @jsonobj.geojson.to_s
    end
end
