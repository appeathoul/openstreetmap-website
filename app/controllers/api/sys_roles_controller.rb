module Api
    class SysRolesController < ApiController

        before_action :authorize, :only => [:find_by_id, :find_all, :delete, :create, :update]
        before_action :check_database_writable, :only => [:create, :update]

        authorize_resource
        

        # 根据id获取角色
        def find_by_id
            @role = SysRole.find(params[:id])

            render :xml => @role.to_xml_node.to_s
        end

        # 获取所有角色
        def find_all
            doc = OSM::API.new.get_xml_doc

            @roles = SysRole.all()
      
            el = XML::Node.new "roles"

            @roles.each do |role|
                @role = SysRole.find(role.id)

                el << @role.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end

        # 根据ids删除角色
        def delete
            ids = params[:ids].split(",")

            ids.each do |id|
                @role = SysRole.find(id)
                @role.delete
            end

            render :plain => true.to_s
        end

        # 创建角色
        def create
            @role = SysRole.new({
                :name => params[:name],
                :order => params[:order],
                :sign => params[:sign]
            })

            # 注：flag为布尔值
            flag = @role.save 

            render :plain => flag.to_s
        end

        # 更新角色信息
        def update
            begin
                @role = SysRole.find(params[:id])

                @role.name = params[:name]
                @role.order = params[:order]
                @role.sign = params[:sign]

                flag = @role.save

                render :plain => flag.to_s
            rescue => exception
                render :plain => exception.to_s
            end
        end
        
    end
end