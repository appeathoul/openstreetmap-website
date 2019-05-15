module Api
    class DeptUsersController < ApiController

        before_action :authorize, :only => [:create,:find_by_dept,:update]
        before_action :check_database_writable, :only => [:create,:update]

        authorize_resource

        # 创建部门与用户关联
        def create
            @dept_user = DeptUser.new({
                :user_id => params[:user_id],
                :dept_id => params[:dept_id]
            })

            # 注：flag为布尔值
            flag = @dept_user.save 

            render :plain => flag.to_s
        end

        # 获取部门所有用户
        def find_by_dept
            doc = OSM::API.new.get_xml_doc
      
            @dept_user = DeptUser.where("dept_id = ?", params[:dept_id])
            @dept = Dept.find(params[:dept_id])
      
            el = XML::Node.new "dept"
            el['dept_id'] = params[:dept_id]
            el['dept_name'] = @dept.name.to_s

            @dept_user.each do |user|
                @user = User.find(user.user_id)

                el << @user.to_xml_node
            end
      
            doc.root << el
            render :xml => doc.to_s
        end
        
        # 更新用户部门（注：传入参数dept_id、user_ids）
        def update
            ids = params[:user_ids].split(",")

            # 删除部门用户
            d_flag = DeptUser.where(:dept_id => params[:dept_id]).delete_all

            if d_flag
                s_flag = true
                
                ids.each do |id|
                    s_flag = save(id,params[:dept_id])
                end
            end

            render :plain => s_flag.to_s

        end

        private

        # 私有方法 创建部门用户关联记录
        def save(user_id,dept_id)
            @dept_user = DeptUser.new({
                :user_id => user_id,
                :dept_id => dept_id
            })

            flag = @dept_user.save

            return flag
        end
    end
end