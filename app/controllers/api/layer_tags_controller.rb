module Api
    class LayerTagsController < ApiController

        before_action :authorize, :only => [:find_by_id, :find_all, :delete, :create, :update]
        before_action :check_database_writable, :only => [:create, :update]

        authorize_resource
        

        # 根据图层编号获取属性
        def find_by_id
            doc = OSM::API.new.get_xml_doc

            # id编号转换为整形
            layer_id = params[:id].to_i

            @tags = LayerTag.where("layer_id = ?",layer_id)
      
            el = XML::Node.new "tags"

            @tags.each do |tag|
                @tag = LayerTag.find(tag.id)

                el << @tag.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end

        # 根据layer_id和keys删除多个属性
        def delete
            layer_id = params[:layer_id].to_i
            keys = params[:keys].split(",")

            flag = false

            keys.each do |key|
                @tag = LayerTag.find_by_layer_id_and_key(layer_id,key)

                # 判断是否存在该属性
                if @tag == nil
                    
                else 
                    flag = !@tag.delete.nil? 
                end 
            end

            render :plain => flag.to_s
        end

        # 创建属性信息
        def create
            if params[:layer_id]
                render :plain => "必须包含图层编号。"
                return
            end

            # 判断
            @tag = LayerTag.new({
                :layer_id => params[:layer_id],
                :key => params[:key].to_s,
                :name => params[:name].to_s,
                :required => !params[:required].nil?,
                :optional_value => params[:optional_value].to_s
            })

            # 注：flag为布尔值
            flag = @tag.save 

            render :plain => flag.to_s
        end

        # 更新属性信息
        def update
            begin
                @tag = LayerTag.find_by_layer_id_and_key(params[:layer_id],params[:key])

                if @tag.nil?
                    render :plain => false.to_s
                    return
                else
                    # 更新属性值时需判断是否传入参数
                    if params[:name]
                        @tag.name = params[:name]
                    end

                    if params[:required] 
                        @tag.required = params[:required]
                    end

                    if params[:optional_value]
                        @tag.optional_value = params[:optional_value]
                    end
                end

                flag = @tag.save

                render :plain => flag.to_s
            rescue => exception
                render :plain => exception.to_s
            end
        end
        
        private

        ##
        # return permitted user parameters
        def tag_params
            params.require(:tag).permit(:layer_id,:key,:name,:required,:optional_value)
        end
    end
end