module Api
    class RoleUsersController < ApiController

        before_action :authorize, :only => [:create,:find_by_user,:update]
        before_action :check_database_writable, :only => [:create,:update]

        authorize_resource

        # 创建角色与用户关联
        def create
            @role_user = RoleUser.new({
                :user_id => params[:user_id],
                :role_id => params[:role_id]
            })

            # 注：flag为布尔值
            flag = @role_user.save 

            render :plain => flag.to_s
        end

        # 获取用户所有角色
        def find_by_user
            doc = OSM::API.new.get_xml_doc
      
            @roles = RoleUser.where("user_id = ?", params[:user_id])
      
            el = XML::Node.new "roles"

            @roles.each do |role|
                @role = SysRole.find(role.role_id)

                el << @role.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end
        
        # 更新用户角色（注：传入参数user_id、role_ids）
        def update
            ids = params[:role_ids].split(",")

            # 删除用户角色
            d_flag = RoleUser.where(:user_id => params[:user_id]).delete_all

            if d_flag
                s_flag = true
                
                ids.each do |id|
                    s_flag = save(params[:user_id],id)
                end
            end

            render :plain => s_flag.to_s

        end

        private

        # 私有方法 创建角色用户关联记录
        def save(user_id,role_id)
            @role_user = RoleUser.new({
                :user_id => user_id,
                :role_id => role_id
            })

            flag = @role_user.save

            return flag
        end
        

    end
end