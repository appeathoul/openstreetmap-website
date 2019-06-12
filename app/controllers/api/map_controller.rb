module Api
  class MapController < ApiController
    authorize_resource :class => false

    before_action :check_api_readable
    around_action :api_call_handle_error, :api_call_timeout

    # This is probably the most common call of all. It is used for getting the
    # OSM data for a specified bounding box, usually for editing. First the
    # bounding box (bbox) is checked to make sure that it is sane. All nodes
    # are searched, then all the ways that reference those nodes are found.
    # All Nodes that are referenced by those ways are fetched and added to the list
    # of nodes.
    # Then all the relations that reference the already found nodes and ways are
    # fetched. All the nodes and ways that are referenced by those ways are then
    # fetched. Finally all the xml is returned.
    def index
      # Figure out the bbox
      # check boundary is sane and area within defined
      # see /config/application.yml
      begin
        bbox = BoundingBox.from_bbox_params(params)
        bbox.check_boundaries
        bbox.check_size
      rescue StandardError => e
        report_error(e.message)
        return
      end

      nodes = Node.bbox(bbox).where(:visible => true).includes(:node_tags).limit(Settings.max_number_of_nodes + 1)

      node_ids = nodes.collect(&:id)
      if node_ids.length > Settings.max_number_of_nodes
        report_error("You requested too many nodes (limit is #{Settings.max_number_of_nodes}). Either request a smaller area, or use planet.osm")
        return
      end

      doc = OSM::API.new.get_xml_doc

      # add bounds
      doc.root << bbox.add_bounds_to(XML::Node.new("bounds"))

      # get ways
      # find which ways are needed
      ways = []
      if node_ids.empty?
        list_of_way_nodes = []
      else
        way_nodes = WayNode.where(:node_id => node_ids)
        way_ids = way_nodes.collect { |way_node| way_node.id[0] }
        ways = Way.preload(:way_nodes, :way_tags).find(way_ids)

        list_of_way_nodes = ways.collect do |way|
          way.way_nodes.collect(&:node_id)
        end
        list_of_way_nodes.flatten!
      end

      # - [0] in case some thing links to node 0 which doesn't exist. Shouldn't actually ever happen but it does. FIXME: file a ticket for this
      nodes_to_fetch = (list_of_way_nodes.uniq - node_ids) - [0]

      nodes += Node.includes(:node_tags).find(nodes_to_fetch) unless nodes_to_fetch.empty?

      visible_nodes = {}
      changeset_cache = {}
      user_display_name_cache = {}

      nodes.each do |node|
        if node.visible?
          doc.root << node.to_xml_node(changeset_cache, user_display_name_cache)
          visible_nodes[node.id] = node
        end
      end

      way_ids = []
      ways.each do |way|
        if way.visible?
          doc.root << way.to_xml_node(visible_nodes, changeset_cache, user_display_name_cache)
          way_ids << way.id
        end
      end

      relations = Relation.nodes(visible_nodes.keys).visible +
                  Relation.ways(way_ids).visible

      # we do not normally return the "other" partners referenced by an relation,
      # e.g. if we return a way A that is referenced by relation X, and there's
      # another way B also referenced, that is not returned. But we do make
      # an exception for cases where an relation references another *relation*;
      # in that case we return that as well (but we don't go recursive here)
      relations += Relation.relations(relations.collect(&:id)).visible

      # this "uniq" may be slightly inefficient; it may be better to first collect and output
      # all node-related relations, then find the *not yet covered* way-related ones etc.
      relations.uniq.each do |relation|
        doc.root << relation.to_xml_node(changeset_cache, user_display_name_cache)
      end

      response.headers["Content-Disposition"] = "attachment; filename=\"map.osm\""

      render :xml => doc.to_s
    end

    # 根据图层标签获取OSM数据
    def find_by_tag

      # 获取查询条件
      where_sql = ""

      if params[:key] && params[:value]
        where_sql = "current_way_tags.k = '" + params[:key]+ "' AND current_way_tags.v = '" + params[:value] + "'"
      else 
        # TODO 后期注释，直接返回语句
        where_sql = "current_way_tags.k = 'regionlevel' AND current_way_tags.v = '2'"
      end

      doc = OSM::API.new.get_xml_doc

      # 根据查询条件获取路径
      ways = Way.includes(:way_nodes).joins(:way_tags).where(where_sql)
      # 遍历输出路径
      ways.each do |way|
        if way.visible?
          # doc.root << way.to_xml_node
          doc.root << way.to_simple_xml_node
        end
      end

      # 获取路径编号集合
      way_ids = ways.collect(&:id)

      visible_nodes = {}

      node_ids = []
      # 遍历输出节点
      ways.each do |way|
        if way.visible?
          # 获取路径节点id集合
          node_ids += way.way_nodes.collect(&:node_id)
        end
      end

      # 获取路径节点
      nodes = Node.where(:id => node_ids.uniq)
      # 获取节点
      nodes.each do |node|
        el = XML::Node.new "node"
        el["id"] = node.id.to_s
        el["lat"] = node.lat.to_s
        el["lon"] = node.lon.to_s
        # doc.root << node.to_xml_node
        doc.root << node.to_simple_xml_node
        visible_nodes[node.id] = node
      end

      # relations = Relation.nodes(visible_nodes.keys).visible +
      #             Relation.ways(way_ids).visible


      # relations += Relation.relations(relations.collect(&:id)).visible

      # relations.uniq.each do |relation|
      #   doc.root << relation.to_xml_node
      # end

      response.headers["Content-Disposition"] = "attachment; filename=\"map.osm\""

      render :xml => doc.to_s
    end


    # 自定义数据过滤接口
    def custom
      # 获取bbox范围
      begin
        bbox = BoundingBox.from_bbox_params(params)
        bbox.check_boundaries
        bbox.check_size
      rescue StandardError => e
        report_error(e.message)
        return
      end

      # 获取查询条件
      if params[:key] && params[:value]
        where_sql = "current_way_tags.k = '" + params[:key]+ "' AND current_way_tags.v = '" + params[:value] + "'"
      end

      # 过滤获取bbox范围内的节点
      nodes = Node.bbox(bbox).where(:visible => true).includes(:node_tags).limit(Settings.max_number_of_nodes + 1)

      # 获取所有节点编号
      node_ids = nodes.collect(&:id)
      # 节点数量超过最大节点数量返回错误
      if node_ids.length > Settings.max_number_of_nodes
        report_error("You requested too many nodes (limit is #{Settings.max_number_of_nodes}). Either request a smaller area, or use planet.osm")
        return
      end

      # 创建XML文档
      doc = OSM::API.new.get_xml_doc

      # add bounds
      doc.root << bbox.add_bounds_to(XML::Node.new("bounds"))

      # get ways
      # find which ways are needed
      # 获取节点相关ways
      ways = []
      if node_ids.empty?
        list_of_way_nodes = []
      else
        # 获取路径与节点关联对象
        way_nodes = WayNode.where(:node_id => node_ids)
        # 获取路径编号
        way_ids = way_nodes.collect { |way_node| way_node.id[0] }
        # 根据查询条件获取way
        ways = Way.joins(:way_tags).where(where_sql)
        # 根据查询条件获取路径编码
        way_ids2 = ways.collect(&:id)
        # 获取路径交集
        ids = way_ids&way_ids2

        ways = Way.preload(:way_nodes, :way_tags).find(ids)

        # 
        list_of_way_nodes = ways.collect do |way|
          way.way_nodes.collect(&:node_id)
        end
        list_of_way_nodes.flatten!
      end

      # 获取范围内节点和路径节点的交集
      nodes_to_fetch = list_of_way_nodes.uniq
      # &node_idsk
      # nodes_to_fetch = (list_of_way_nodes.uniq - node_ids) - [0]
      # 获取节点对象集合
      nodes = Node.includes(:node_tags).find(nodes_to_fetch)
      # nodes += Node.includes(:node_tags).find(nodes_to_fetch) unless nodes_to_fetch.empty?

      visible_nodes = {}
      changeset_cache = {}
      user_display_name_cache = {}

      nodes.each do |node|
        if node.visible?
          doc.root << node.to_xml_node(changeset_cache, user_display_name_cache)
          visible_nodes[node.id] = node
        end
      end

      way_ids = []
      ways.each do |way|
        if way.visible? && !nodes.nil?
          doc.root << way.to_xml_node(visible_nodes, changeset_cache, user_display_name_cache)
          way_ids << way.id
        end
      end

      relations = Relation.nodes(visible_nodes.keys).visible +
                  Relation.ways(way_ids).visible

      # we do not normally return the "other" partners referenced by an relation,
      # e.g. if we return a way A that is referenced by relation X, and there's
      # another way B also referenced, that is not returned. But we do make
      # an exception for cases where an relation references another *relation*;
      # in that case we return that as well (but we don't go recursive here)
      relations += Relation.relations(relations.collect(&:id)).visible

      # this "uniq" may be slightly inefficient; it may be better to first collect and output
      # all node-related relations, then find the *not yet covered* way-related ones etc.
      relations.uniq.each do |relation|
        doc.root << relation.to_xml_node(changeset_cache, user_display_name_cache)
      end

      response.headers["Content-Disposition"] = "attachment; filename=\"map.osm\""

      render :xml => doc.to_s



    end

    def xml_from_way(way)
      el = XML::Node.new "way"
      el["id"] = way.id.to_s

      add_metadata_to_xml_node(el, way)

      way.way_nodes.each do |nd|  
        node_el = XML::Node.new "nd"
        node_el["ref"] = nd.node_id
        el << node_el
      end

      add_tags_to_xml_node(el,way. way_tags)
    end
    
  end
end
