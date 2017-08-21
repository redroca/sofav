class BaseDecorator < Draper::Decorator
  extend Dry::Configurable

  # 对应的model class
  setting :model

  DEFINITIONS = {
    # 属性定义列表
    attribute_types: {},

    # index page用到的字段/筛选/搜索
    collection_filters: [],
    collection_search: {},
    collection_attributes: [],

    # new/edit page用到的字段列表
    form_attributes: [],
    edit_form_attributes: [],

    # show page 用到的字段列表
    show_page_attributes: [],

    # class/instance 操作列表
    permitted_class_methods: {},
    permitted_instance_methods: {},

    extra_permitted_attributes: {}
  }.freeze

  DEFINITIONS.each do |key, default_value|
    setting key, default_value
    delegate key, to: :class
  end

  def human(field)
    value = try("human_#{field}") || try(field) || object.try("#{field}_text") || object.try(field)
    value = field.split('.').inject(object) {
      |result, method| result.try(method)
    } if field.include?('.')

    case value
      when ActiveSupport::TimeWithZone
        value.strftime('%Y-%m-%d %H:%M:%S')
      when TrueClass
        I18n.t("#{field}.true_html", default: '-').html_safe
      when FalseClass
        I18n.t("#{field}.false_html", default: '-').html_safe
      else
        value.presence || '-'
    end
  end

  class << self
    delegate :model, to: :config

    def inherited(subclass)
      super

      subclass.configure do |config|
        config.model = subclass.name.remove(/Decorator\Z/).singularize.safe_constantize

        scope = config.model.model_name.singular
        config.attribute_types = I18n.t(['attribute_types', scope].join('.'), default: {}).deep_dup
        I18n.t(['decorator', scope].join('.'), default: {}).map { |key, value| config.send("#{key}=", value) }

        config.model.columns_hash.each do |name, col|
          name = name.to_sym
          if config.attribute_types[name].nil?
            if col.array
              config.attribute_types[name] = {
                  type: 'collection_select',
                  collection: '[]',
                  text_method: :last,
                  value_method: :first,
                }
            else
              case col.type
              when 'integer', 'float'
                config.attribute_types[name] = {
                  type: 'number_field',
                  required: false
                }
              when 'datetime'
                config.attribute_types[name] = {
                  type: 'datetime_select',
                  required: false
                }
              when 'boolean'
                config.attribute_types[name] = {
                  type: 'collection_check_boxes',
                  required: false
                }
              when 'date'
                config.attribute_types[name] = {
                  type: 'date_select',
                  required: false
                }
              else
                config.attribute_types[name] = {
                  type: 'text_field',
                  required: false
                }
              end
            end

          end
        end

      end
    end

    # 设置对应的class
    def decorate_to(klass)
      config.model = klass
    end

    DEFINITIONS.keys.each do |method_name|
      define_method(method_name) { |&block|
        if block
          config.send("#{method_name}=", block.call)
        else
          config.send(method_name)
        end
      }
    end

    # 获取某个属性的定义
    def attribute_type_for(attribute_name, quiet = false)
      config.attribute_types.fetch(attribute_name.to_sym) do
        fail attribute_not_found_message(attribute_name) unless quiet
      end.deep_dup
    end

    # 表单必填字段列表
    def required_attributes
      config.attribute_types.collect { |name, field| name if field[:required] }.compact
    end

    # 表单允许提交的参数
    def permitted_attributes
      _attributes = config.form_attributes

      if _attributes.is_a?(Hash)
        profiles = _attributes.fetch(:profiles, [])
        _attributes = profiles.collect { |profile| _attributes.fetch(profile.to_sym, []) }.flatten.uniq
        # _attributes = _attributes.each {|attr| _attributes << "#{attr}_attributes"}
      end

      array, hash = [], {}
      _attributes.each do |field_name|
        attribute_type_for(field_name)[:is_array] ? hash.merge!(field_name => []) : array.push(field_name)
      end

      [array, hash].append(config.extra_permitted_attributes)
      #.append(filters: config.collection_filters.keys)
    end

    def permitted_class_methods_for(action_name)
      config.permitted_class_methods.fetch(action_name.to_sym, [])
    end

    def permitted_instance_methods_for(action_name)
      config.permitted_instance_methods.fetch(action_name.to_sym, [])
    end

    private

    def attribute_not_found_message(attribute_name)
      "Attribute #{attribute_name} could not be found in #{self}.attribute_types"
    end
  end
end
