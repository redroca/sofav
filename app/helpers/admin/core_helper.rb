module Admin
  module CoreHelper
    # BREADCRUMB_PREFIX_ACTION = %w{new edit}.freeze
    # BREADCRUMB_SUFFIX_ACTION = %w{index show}.freeze
    #
    # %i{model decorator current_studio records record}.map { |method_name|
    #   delegate method_name, to: :controller
    # }
    #
    # def full_controller_name
    #   params[:controller]
    # end
    #
    # def full_controller_name_human
    #   if controller_name == 'settings'
    #     t("breadcrumb.#{full_controller_name}")
    #   else
    #     [t("breadcrumb.#{full_controller_name}"), '系统'].join
    #   end
    # end
    #
    # def full_controller_link
    #   full_controller_name.sub('admin', '#!')
    # end
    #
    # def default_action_name_human
    #   if BREADCRUMB_PREFIX_ACTION.include?(action_name)
    #     [t("actions.#{action_name}"), t("breadcrumb.#{full_controller_name}")].join
    #   elsif BREADCRUMB_SUFFIX_ACTION.include?(action_name)
    #     [t("breadcrumb.#{full_controller_name}"), t("actions.#{action_name}")].join
    #   else
    #     '默认导航'
    #   end
    # end
    #
    # def full_action_name_human
    #   t("breadcrumb.#{full_controller_name}/#{action_name}", default: default_action_name_human)
    # end
    #
    # # 添加对象按钮
    # def new_model_tag(target_model = nil)
    #   model_name = (target_model || controller_name).singularize
    #   model_human_name = [t('actions.new'), t("activerecord.models.#{model_name}")].join
    #   target_link = ['#!', target_model || controller_name, :new].join('/')
    #   content_tag(:div, class: 'pull-right btn-groups') do
    #     link_to(model_human_name, target_link, class: 'btn btn-primary clearfix')
    #   end
    # end
    #
    # # 筛选栏
    # def filters_tag(target_model = nil, filters_name = nil)
    #   (_model = target_model || model).blank? and return
    #   (_decorator = _model.decorator).blank? and return
    #
    #   filters = Array(_decorator.try(filters_name || :index_filters))
    #   filters.collect { |filter_key, filter_name|
    #     content_tag(:div, class: 'pull-left dropdown filters') do
    #       html = []
    #       html << button_tag(type: 'button', name: filter_key, class: 'btn btn-default',
    #                          data: {toggle: 'dropdown'},
    #                          aria: {haspopup: true, expanded: false}) do
    #         [filter_name, content_tag(:span, nil, class: 'caret')].join.html_safe
    #       end
    #
    #       html << content_tag(:ul, class: 'dropdown-menu') do
    #         _decorator.filter_for(filter_key)
    #       end
    #       html.join.html_safe
    #     end
    #   }.join.html_safe
    # end

    # # 搜索栏
    # def search_tag(target_model = nil, search_name = nil)
    #   (_model = target_model || model).nil? and return
    #   (_decorator = _model.decorator).blank? and return
    #   (searches = _decorator.try(search_name || :index_searches)).blank? and return
    #
    #   html = []
    #   name, placeholder, action = searches.values_at(:name, :placeholder, :action)
    #   form_tag(action, class: 'pull-right', method: :get, enforce_utf8: false) do
    #     html << text_field_tag(name, params[name], placeholder: placeholder)
    #     html << button_tag(type: nil, name: nil) do
    #       content_tag(:i, nil, class: 'glyphicon glyphicon-search')
    #     end
    #     html.join.html_safe
    #   end
    # end

    # # 行数据的操作列表
    # def render_actions(record)
    #   (_decorate = record.try(:decorate)).blank? and return
    #   (_decorate.try(:manage_actions) || {}).collect { |action|
    #     render("admin/shared/actions/#{action}", record: record)
    #   }.join.html_safe
    # end
    #
    # # 列表栏表头
    # def table_thead_tag(target_model = nil)
    #   (_model = target_model || model).blank? and return
    #   (_decorator = _model.decorator).blank? and return
    #   (list_fields = _decorator.try(:list_fields)).blank? and return
    #
    #   content_tag(:thead) do
    #     content_tag(:tr) do
    #       ths = list_fields.collect { |field| content_tag(:th, _model.human_attribute_name(field)) }
    #       ths << content_tag(:th, t('action')) if _decorator.try(:class_actions)
    #       ths.join.html_safe
    #     end
    #   end
    # end
    #
    # # 列表页数据内容
    # def table_tbody_tag(target_records = nil)
    #   (_records = target_records || records).blank? and return
    #
    #   trs = []
    #   content_tag(:tbody) do
    #     _records.each do |record|
    #       _decorate = record.decorate
    #
    #       trs << content_tag(:tr) do
    #         tds = _decorate.try(:list_fields).collect { |field| content_tag(:td, record.human_field(field)) }
    #         tds << content_tag(:td, render_actions(record)) if _decorate.try(:manage_actions)
    #         tds.join.html_safe
    #       end
    #     end
    #     trs.join.html_safe
    #   end
    # end
    #
    # # 数据列表
    # def records_list_tag(target_records = nil)
    #   content_tag(:table, class: 'table table-striped') do
    #     _records = target_records || records
    #     target_model = _records.class.to_s.deconstantize.safe_constantize
    #     html = [table_thead_tag(target_model)]
    #     html << table_tbody_tag(_records) if _records.present?
    #     html.join.html_safe
    #   end
    # end
    #
    # # 翻页控件
    # def paginate_tag(target_records = nil)
    #   paginate(target_records || records, theme: 'admin')
    # end

    # 详情页操作按钮
    def show_manage_actions_tag(target_record = nil)
      _record = target_record || record
      (_decorate = _record.try(:decorate)).blank? and return
      (_decorate.try(:manage_actions) || {}).collect { |action|
        render("admin/shared/actions/#{action}", record: record)
      }.join.html_safe
    end

    # 页面表单元素列表
    def form_fields_list_tag(form_builder, target_fields, target_model = nil)
      (_model = target_model || model).blank? and return
      (_decorator = _model.decorator).blank? and return
      (_fields = _decorator.try(target_fields)).blank? and return

      if _fields.is_a?(Hash)
        _fields.collect { |profile, items|
          _html = []
          _html << content_tag(:h3, t("profiles.#{profile}"), class: 'lead clearfix')
          _html << content_tag(:ul, class: 'row list-unstyled') do
            items.collect { |field, partial, options|
              render "admin/shared/fields/#{partial}", {f: form_builder, field: field, options: options || {}}
            }.join.html_safe
          end
          _html.join.html_safe
        }.join.html_safe
      elsif _fields.is_a?(Array)
        _fields.collect { |field, partial, options|
          render "admin/shared/fields/#{partial}", {f: form_builder, field: field, options: options || {}}
        }.join.html_safe
      else
      end
    end

    # 添加页面表单元素列表
    def new_fields_list_tag(form_builder, target_model = nil)
      form_fields_list_tag(form_builder, :new_fields, target_model)
    end

    # 编辑页面表单元素列表
    def edit_fields_list_tag(form_builder, target_model = nil)
      form_fields_list_tag(form_builder, :edit_fields, target_model)
    end

    # 表单页脚
    def form_footer_tag(form_builder)
      html = []
      html << content_tag(:h3, nil, class: 'lead clearfix')
      html << content_tag(:div, class: 'row') do
        content_tag(:div, class: 'col-sm-12') do
          _html = []
          _html << form_builder.button(type: 'submit', name: nil, class: 'btn-icon btn btn-info') do
            '<i class="glyphicon glyphicon-check"></i><span>提交</span>'.html_safe
          end
          _html << form_builder.button(type: 'reset', name: nil, class: 'btn-icon btn btn-warning') do
            '<i class="glyphicon glyphicon-repeat"></i><span>重置</span>'.html_safe
          end
          _html.join.html_safe
        end
      end
      html.join.html_safe
    end

    # # 返回列表
    # def back_to_list_tag(target_model = nil)
    #   (_model = target_model || model).blank? and return
    #   link_to [:admin, _model] do
    #     ['<i class="fa fa-angle-double-left"></i>', t('action.back_to_list')].join(' ').html_safe
    #   end
    # end

    # # 详情页表内容
    # def show_table_tbody_tag(record, target_fields = nil)
    #   _model, _fields = record.class, target_fields || :show_fields
    #   (_decorator = _model.decorator).blank? and return
    #
    #   trs = []
    #   content_tag(:tbody) do
    #     _decorator.try(_fields).each do |field|
    #       trs << content_tag(:tr) do
    #         [content_tag(:td, _model.human_attribute_name(field), class: 'mnw150', width: '150px'),
    #          content_tag(:td, record.human_field(field))].join.html_safe
    #       end
    #     end
    #
    #     trs.join.html_safe
    #   end
    # end
  end
end
