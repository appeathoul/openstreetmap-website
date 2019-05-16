module Api
    class LayersController < ApiController

        before_action :authorize, :only => [:find_by_id, :find_all, :delete, :create, :update]
        before_action :check_database_writable, :only => [:create, :update]

        authorize_resource
         
        # 根据id获取图层
        def find_by_id
            @layer = Layer.find(params[:id])

            render :xml => @layer.to_xml_node.to_s
        end

        # 获取所有图层
        def find_all
            doc = OSM::API.new.get_xml_doc

            @layers = Layer.all()
      
            el = XML::Node.new "layers"

            @layers.each do |layer|
                @layer = Layer.find(layer.id)

                el << @layer.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end

        # 根据ids删除图层
        def delete
            ids = params[:ids].split(",")

            ids.each do |id|
                @layer = Layer.find(id)
                @layer.delete
            end

            render :plain => true.to_s
        end

        # 创建图层
        def create
            @layer = Layer.new({
                :name => params[:name],
                :itype => params[:itype],
                :status => params[:status],
                :sign => params[:sign]
            })

            # 注：flag为布尔值
            flag = @layer.save 

            render :plain => flag.to_s
        end

        # 更新图层信息
        def update
            begin
                @layer = Layer.find(params[:id])

                # 更新属性值时需判断是否传入参数
                if params[:name]
                    @layer.name = params[:name]
                end

                if params[:geotype] 
                    @layer.geotype = params[:geotype]
                end

                if params[:itype] 
                    @layer.itype = params[:itype]
                end

                if params[:order]
                    @layer.order = params[:order]
                end

                if params[:sign]
                    @layer.sign = params[:sign]
                end

                if params[:icon]
                    @layer.icon = params[:icon]
                end

                if params[:region_code]
                    @layer.region_code = params[:region_code]
                end

                flag = @layer.save

                render :plain => flag.to_s
            rescue => exception
                render :plain => exception.to_s
            end
        end
        
    end
end