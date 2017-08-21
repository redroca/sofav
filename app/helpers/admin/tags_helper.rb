module Admin
  module TagsHelper
    def breadcrumb_tag(controller, action_name)
      tag_1 = link_to(controller.controller_name_human, url_for(controller: controller_path))
      tag_2 = link_to(controller.action_name_human(action_name), 'javascript:;', class: 'active')
      tag_1.concat(tag_2)
    end

    # 添加对象按钮
    # TODO 添加权限
    def new_model_tag(klass)
      name = [t('actions.new'), klass.model_name.human].join
      url = url_for(controller: klass.model_name.route_key, action: 'new')
      html_options = {class: 'btn btn-primary clearfix'}
      link_to(name, url, html_options)
    end

    def filter_tag(decorator, filter_key, filter_name)
      button_text = [filter_name, content_tag(:span, nil, class: 'caret')].join("\n").html_safe
      button_options = {type: 'button', name: filter_key}
      button_html_options = {class: 'btn btn-default btn-sm', data: {toggle: 'dropdown'}, aria: {haspopup: true, expanded: false}}

      content_tag(:div, class: 'pull-left dropdown filters') do
        concat(button_tag(button_text, button_options.merge(button_html_options)))
        concat(content_tag(:ul, decorator.filter_for(filter_key), class: 'dropdown-menu'))
      end
    end

    # 筛选栏
    def collection_filters_tag(decorator, filters_name)
      Array(decorator.try(filters_name)).each do |filter_key, filter_name|
        concat(filter_tag(decorator, filter_key, filter_name))
      end

      # 这里要返回nil,因为用的each 有额外的返回值
      nil
    end

    # 搜索栏
    def collection_search_tag(decorator, search_name)
      (search_options = decorator.try(search_name)).blank? and return

      name, placeholder, action = search_options.values_at(:name, :placeholder, :action)
      form_tag(action, class: 'pull-right collection_search', method: :get, enforce_utf8: false) do
        concat(text_field_tag(name, params[name], placeholder: placeholder))
        concat(button_tag(content_tag(:i, nil, class: 'glyphicon glyphicon-search'), type: nil, name: nil))
      end
    end

    # 列表栏表头
    def table_thead_tag(model, decorator, attribute_name)
      (collection_attributes = decorator.try(attribute_name)).blank? and return

      content_tag(:thead) do
        content_tag(:tr) do
          collection_attributes.map { |field| concat(content_tag(:th, model.human_attribute_name(field))) }
          concat(content_tag(:th, t('action'))) if decorator.permitted_instance_methods_for(action_name)
        end
      end
    end

    def render_class_actions(decorator)
      Array(decorator.permitted_class_methods_for(action_name)).collect { |action|
        render_to_string("actions/#{action}", layout: false)
      }.join("\n").html_safe
    end

    # 列表页操作按钮
    def render_instance_actions(decorate)
      Array(decorate.class.permitted_instance_methods_for(action_name)).collect { |action|
        render_to_string("actions/index_#{action}", locals: {record: decorate.object}, layout: false)
      }.join("\n").html_safe
    end

    # 列表页数据内容
    def table_tbody_tag(records, decorator, attribute_name, options)
      per_page = options.delete(:per_page)
      content_tag(:tbody) do
        records.each_with_index do |record, index|
          decorate = decorator.new(record)

          tds = Array(decorate.try(attribute_name)).collect do |field|
            td_val = field == '#' ? (( records.current_page - 1 ) * (per_page || records.default_per_page)) + index + 1 : decorate.human(field)
            content_tag(:td, td_val)
          end.join("\n").html_safe
          tds.concat(content_tag(:td, render_instance_actions(decorate))) if decorator.permitted_instance_methods_for(action_name)
          concat(content_tag(:tr, tds, 'data-id' => record.id))
        end
      end
    end

    # 列表table
    def collection_table_tag(records, decorator, attribute_name, options = {})
      content_tag(:table, class: 'table table-hover', id: decorator.model.name.downcase.pluralize) do
        concat(table_thead_tag(records.model, decorator, attribute_name))
        concat(table_tbody_tag(records, decorator, attribute_name, options))
        concat(hidden_field_tag(:per_page, records.limit_value))
        concat(hidden_field_tag(:current_page, records.current_page))
        concat(hidden_field_tag(:is_last_page, records.last_page?))
        concat(hidden_field_tag(:total_pages, records.total_pages))
      end
    end
  end
end
