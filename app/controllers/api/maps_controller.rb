module Api
    class MapsController < ApiController

        before_action :authorize, :only => [:find_by_id, :find_all, :delete, :create, :update, :update_map_of_user, :delete_map_of_user,:find_map_of_user]
        before_action :check_database_writable, :only => [:create, :update, :update_map_of_user]

        authorize_resource
        
        # 根据id获取地图
        def find_by_id
            @map = Map.find(params[:id])

            render :xml => @map.to_xml_node.to_s
        end

        # 获取所有地图
        def find_all
            doc = OSM::API.new.get_xml_doc

            @maps = Map.all()
      
            el = XML::Node.new "maps"

            @maps.each do |map|
                @map = Map.find(map.id)

                el << @map.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end

        # 根据ids删除地图
        def delete
            ids = params[:ids].split(",")

            ids.each do |id|
                @map = Map.find(id)
                @map.delete
            end

            render :plain => true.to_s
        end

        # 创建角色
        def create
            @map = Map.new({
                :name => params[:name],
                :url => params[:url],
                :order => params[:order],
                :default => params[:default]
            })

            # 注：flag为布尔值
            flag = @map.save 

            render :plain => flag.to_s
        end

        # 更新地图信息
        def update
            begin
                @map = Map.find(params[:id])

                # 更新属性值时需判断是否传入参数
                if params[:name]
                    @map.name = params[:name]
                end

                if params[:url] 
                    @map.url = params[:url]
                end

                if params[:order]
                    @map.order = params[:order]
                end

                if params[:default]
                    @map.default = params[:default]
                end

                flag = @map.save

                render :plain => flag.to_s
            rescue => exception
                render :plain => exception.to_s
            end
        end

        # 更新用户背景地图
        def update_map_of_user

            flag = false

            begin
                @prefence = UserPreference.where("user_id = ? AND k = 'background_maps'", params[:user_id]).take!

                @prefence.v = params[:map_ids]

                flag = @prefence.save 

                render :plain => flag.to_s
            rescue ActiveRecord::RecordNotFound
                @prefence = UserPreference.new({
                    :user_id => params[:user_id],
                    :k => 'background_maps',
                    :v => params[:map_ids]
                })

                flag = @prefence.save 

                render :plain => flag.to_s
            end
        end

        # 删除用户背景地图配置
        def delete_map_of_user
            @prefences = UserPreference.where("user_id = ? AND k = 'background_maps'", params[:user_id])

            @prefences.each do |prefence|
                prefence.delete
            end
     
            render :plain => true.to_s
        end
        
        # 获取用户地图配置
        def find_map_of_user
            doc = OSM::API.new.get_xml_doc
            el = XML::Node.new "maps"

            @prefences = UserPreference.where("user_id = ? AND k = 'background_maps'", params[:user_id])

            if @prefences.length == 1
                @map_ids = @prefences[0].v.split(',')

                @map_ids.each do |id|
                    @map = Map.find(id)
                    el << @map.to_xml_node
                end
            else
                @maps = Map.all()
      
                @maps.each do |map|
                    @map = Map.find(map.id)
                    el << @map.to_xml_node
                end
            end

            doc.root << el

            render :xml => doc.to_s
        end
        
    end
end