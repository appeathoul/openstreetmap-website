module Api
    class TemplatesController < ApiController

        before_action :authorize, :only => [:find_by_id, :find_all, :delete, :create, :update, :update_tmpl_of_user, :delete_tmpl_of_user,:find_tmpl_of_user]
        before_action :check_database_writable, :only => [:create, :update]

        authorize_resource
        
        # 根据id获取模板
        def find_by_id
            # @tmpl = Template.find(params[:id])

            # doc = OSM::API.new.get_xml_doc
            # el = @tmpl.to_xml_node

            # el_layers = XML::Node.new "layers"

            # @tmpl.layers.each do |layer|
            #     @layer = Layer.find(layer.layer_id)

            #     el_layers << @layer.to_xml_node
            # end

            # el << el_layers
            # doc.root << el

            # render :xml => doc.to_s

            # 生成包含模板、图层、属性信息的xml
            el = tmpl_to_xml(params[:id])

            doc = OSM::API.new.get_xml_doc

            doc.root << el

            render :xml => doc.to_s
        end

        # 获取所有模板
        def find_all
            doc = OSM::API.new.get_xml_doc

            @tmpls = Template.all()
      
            el = XML::Node.new "templates"

            @tmpls.each do |tmpl|
                @tmpl = Template.find(tmpl.id)

                el << @tmpl.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end

        # 根据ids删除模板
        def delete
            ids = params[:ids].split(",")

            ids.each do |id|
                @tmpl = Template.find(id)
                @tmpl.delete
            end

            render :plain => true.to_s
        end

        # 创建角色
        def create
            @tmpl = Template.new({
                :name => params[:name],
                :itype => params[:itype],
                :status => params[:status],
                :sign => params[:sign]
            })

            # 注：flag为布尔值
            flag = @tmpl.save 

            render :plain => flag.to_s
        end

        # 更新模板信息
        def update
            begin
                @tmpl = Template.find(params[:id])

                # 更新属性值时需判断是否传入参数
                if params[:name]
                    @tmpl.name = params[:name]
                end

                if params[:itype] 
                    @tmpl.itype = params[:itype]
                end

                if params[:sign]
                    @tmpl.sign = params[:sign]
                end

                if params[:status]
                    @tmpl.status = params[:status]
                end

                flag = @tmpl.save

                render :plain => flag.to_s
            rescue => exception
                render :plain => exception.to_s
            end
        end

        # 更新用户背景地图
        def update_tmpl_of_user

            flag = false

            begin
                @prefence = UserPreference.where("user_id = ? AND k = 'template'", params[:user_id]).take!

                @prefence.v = params[:tmpl_id]

                flag = @prefence.save 

                render :plain => flag.to_s
            rescue ActiveRecord::RecordNotFound
                @prefence = UserPreference.new({
                    :user_id => params[:user_id],
                    :k => 'template',
                    :v => params[:tmpl_id]
                })

                flag = @prefence.save 

                render :plain => flag.to_s
            end
        end

        # 删除用户背景地图配置
        def delete_tmpl_of_user
            @prefences = UserPreference.where("user_id = ? AND k = 'template'", params[:user_id])

            @prefences.each do |prefence|
                prefence.delete
            end
     
            render :plain => true.to_s
        end
        
        # 获取用户地图配置
        def find_tmpl_of_user
            doc = OSM::API.new.get_xml_doc
            el = XML::Node.new "templates"

            @prefences = UserPreference.where("user_id = ? AND k = 'template'", params[:user_id])

            if @prefences.length == 1
                tmpl_id = @prefences[0].v

                el << tmpl_to_xml(tmpl_id)
            end

            doc.root << el

            render :xml => doc.to_s
        end

        private

        # 模板信息转xml
        def tmpl_to_xml(tmpl_id)
            # 获取模板对象
            @tmpl = Template.find(tmpl_id)
            # 模板xml
            el = @tmpl.to_xml_node
            # 图层根结点
            el_layers = XML::Node.new "layers"
            # 绑定模板包含图层
            @tmpl.layers.each do |layer|
                @layer = Layer.find(layer.layer_id)
                # 单个图层节点
                el_layer =  @layer.to_xml_node
                # 图层属性节点
                el_tags = XML::Node.new "tags"

                @layer.tags.each do |tag|
                    el_tags << tag.to_xml_node
                end

                el_layer << el_tags
                el_layers << el_layer

            end

            el << el_layers
            
            return el
        end
        
    end
end