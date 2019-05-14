module Api
    class DeptsController < ApiController

        before_action :authorize, :only => [:find_by_id, :find_all, :delete, :create, :update]
        before_action :check_database_writable, :only => [:create, :update]

        authorize_resource
        

        # 根据id获取角色
        def find_by_id
            @role = Dept.find(params[:id])

            render :xml => @role.to_xml_node.to_s
        end

        # 获取所有角色
        def find_all
            doc = OSM::API.new.get_xml_doc

            @depts = Dept.all()
      
            el = XML::Node.new "depts"

            @depts.each do |dept|
                @dept = Dept.find(dept.id)

                el << @dept.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end

        # 根据ids删除角色
        def delete
            ids = params[:ids].split(",")

            ids.each do |id|
                @role = Dept.find(id)
                @role.delete
            end

            render :plain => true.to_s
        end

        # 创建角色
        def create
            @Dept = Dept.new({
                :name => params[:name],
                :parent_id => params[:parent_id]
                :order => params[:order],
                :sign => params[:sign]
            })

            # 注：flag为布尔值
            flag = @Dept.save 

            render :plain => flag.to_s
        end

        # 更新角色信息
        def update
            begin
                @Dept = Dept.find(params[:id])

                @Dept.name = params[:name]
                @Dept.parent_id = params[:parent_id]
                @Dept.order = params[:order]
                @Dept.sign = params[:sign]

                flag = @Dept.save

                render :plain => flag.to_s
            rescue => exception
                render :plain => exception.to_s
            end
        end
        
    end
end