module Admin
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :model, :decorator, :decorate, :record, :records, :concat, to: :@template

    def label_tag(method, options = {})
      label_class = Array(options[:label_class]) || []
      label_class << ['control-label', options[:block] ? 'col-sm-2' : 'col-sm-4'] if label_class.blank?
      label_class << 'required' if options[:required]
      @template.content_tag(:label, model.human_attribute_name(method), class: label_class.flatten)
    end

    def input_dom_id(field_name)
      '_form_id_'.concat(field_name.to_s)
    end

    def field_wrapper(method, options = {}, &block)
      label_options = options.extract!(:label_class, :required, :block)
      is_block = label_options[:block]
      show_label = options.delete(:show_label)
      options[:class] ||= 'form-control'
      options.merge!(id: input_dom_id(method))

      @template.content_tag(:li, class: is_block ? 'col-sm-12' : 'col-sm-6') do
        @template.content_tag(:div, class: 'form-group') do
          content = (show_label.nil? || show_label) ? [label_tag(method, label_options)] : [@template.content_tag(:div, class: 'col-sm-2'){}]
          content << @template.content_tag(:div, yield(block), class: is_block ? 'col-sm-10' : 'col-sm-8')
          content.join.html_safe
        end
      end
    end

    def admin_nested_fields(method, options = {})
      field_wrapper(method, options) do
        fields_content = []
        fields_content << @template.content_tag(:div, id: "#{method}_nested_form") do
          nested_content = []
          nested_content << self.fields_for(method.to_sym) do |ff|
            @template.render("#{method.to_s.singularize}_fields", f: ff)
          end

          nested_content << @template.content_tag(:div, class: 'col-sm-12') do
            btns_content = [@template.link_to_add_association('添加', self, method.to_sym, class: 'btn btn-sm btn-success'), "&nbsp;"]
            btns_content << @template.button_tag(:input, class: "sort-btn btn btn-sm btn-success", type: "button", id: "#{method}-sort-btn") { "排序" }
            btns_content.join.html_safe
          end

          nested_content.join.html_safe
        end

        fields_content << @template.render("admin/application/partials/sort_script",
          sort_btn_id: "##{method}-sort-btn",
          container_id: "##{method}_nested_form",
          resource_parts: method.pluralize)

        fields_content << @template.content_tag(:script) do
          %(
            $(document).on('turbolinks:load', function () {
              Cocoon();
            });
          ).html_safe
        end
        fields_content.join.html_safe
      end
    end

    def admin_render_field(method, options = {})
      field_wrapper(method, options) do
        @template.render("#{method.to_s.singularize}", f: self)
      end
    end

    def admin_display_field(method, options = {})
      field_wrapper(method, options) do
        @template.content_tag(:span, record.try(method))
      end
    end

    def admin_text_field(method, options = {})
      field_wrapper(method, options) do
        @template.text_field(@object_name, method, objectify_options(options))
      end
    end

    def admin_password_field(method, options = {})
      field_wrapper(method, options) do
        @template.password_field(@object_name, method, objectify_options(options))
      end
    end

    def admin_number_field(method, options = {})
      field_wrapper(method, options) do
        @template.number_field(@object_name, method, objectify_options(options))
      end
    end

    def admin_generic_field(type, method, options = {})
      field_wrapper(method, options) do
        send type, @object_name, method, objectify_options(options)
      end
    end

    def admin_file_field(method, options = {})
      file_url = record.try(method)
      file_url = file_url.class.superclass == CarrierWave::Uploader::Base ? file_url.try('url') : file_url

      field_wrapper(method, options) do
        content = [@template.file_field(@object_name, method, objectify_options(options))]
        content << @template.link_to(file_url, target: '_blank') {"点击查看"}
        content.join.html_safe
      end
    end

    def admin_image_field(method, options = {})
      field_wrapper(method, options) do
        img_url = record.try(method)
        img_url = img_url.class.superclass == CarrierWave::Uploader::Base ? img_url.try('url') : img_url
        content = [@template.link_to(img_url, target: '_blank') do
          decorate.respond_to?("human_#{method}") ? decorate.human(method) : @template.image_tag(img_url)
        end]
        content << @template.file_field(@object_name, method, objectify_options(options))
        content.join.html_safe
      end
    end

    def admin_collection_check_boxes(method, options = {})
      collection, value_method = options.delete(:collection), options.delete(:value_method)
      text_method, html_options = options.delete(:text_method), options.delete(:html_options) || {}
      field_wrapper(method, options) do
        @template.collection_check_boxes(@object_name, method, eval(collection), value_method, text_method, objectify_options(options), @default_options.merge(html_options)) do |b|
          @template.content_tag(:span) { [b.check_box, b.text].join(' ').html_safe }
        end
      end
    end

    def admin_collection_select2(method, options = {})
      collection, value_method = options.delete(:collection), options.delete(:value_method)
      text_method, html_options = options.delete(:text_method), options.delete(:html_options) || {}
      is_array = options.delete(:is_array)
      select2_options = options.delete(:select2_options)
      options.merge!(prompt: true)
      html_options.merge!(options.extract!(:label_class, :required, :block))
      html_options.merge!(name: "#{@object_name}[#{method}][]") if is_array
      sel_scripts = field_wrapper(method, html_options) do
        @template.collection_select(@object_name, method, eval(collection), value_method, text_method, objectify_options(options), @default_options.merge(html_options))
      end
      select2_scripts = @template.content_tag(:script) { "$('##{input_dom_id(method)}').select2(#{select2_options.to_json});".html_safe }
      sel_scripts.concat(select2_scripts)
    end

    def admin_collection_select(method, options = {})
      collection, value_method = options.delete(:collection), options.delete(:value_method)
      text_method, html_options = options.delete(:text_method), options.delete(:html_options) || {}
      is_array = options.delete(:is_array)
      options.merge!(prompt: true)
      html_options.merge!(options.extract!(:label_class, :required, :block))
      html_options.merge!(name: "#{@object_name}[#{method}][]") if is_array
      field_wrapper(method, html_options) do
        @template.collection_select(@object_name, method, eval(collection), value_method, text_method, objectify_options(options), @default_options.merge(html_options))
      end
    end

    def admin_text_area(method, options = {})
      field_wrapper(method, options) do
        @template.text_area(@object_name, method, objectify_options(options))
      end
    end

    def admin_date_select(method, options = {})
      field_wrapper(method, options) do
        options[:class] = [options[:class], 'datepicker'].flatten
        @template.text_field(@object_name, method, objectify_options(options))
      end
    end

    def admin_datetime_select(method, options = {})
      field_wrapper(method, options) do
        options[:class] = [options[:class], 'datetimepicker'].flatten
        @template.text_field(@object_name, method, objectify_options(options))
      end
    end

    def admin_collection_radio_buttons(method, options = {})
      collection, value_method = options.delete(:collection), options.delete(:value_method)
      text_method, html_options = options.delete(:text_method), options.delete(:html_options) || {}
      field_wrapper(method, options) do
        @template.collection_radio_buttons(@object_name, method, eval(collection), value_method, text_method, objectify_options(options), @default_options.merge(html_options)) do |b|
          @template.content_tag(:span, style: 'height: 34px;display: inline-block;') { [b.radio_button, b.text].join(' ').html_safe }
        end
      end
    end

    def build_form_for(decorator, *attribute_name_list)
      fields_hash = []
      attribute_name_list.each do |attribute_name|
        fields_hash = decorator.try(attribute_name)
        break if !fields_hash.empty?
      end
      if fields_hash.empty?
        fields_hash = decorator.try(:new_attributes)
      end
      profiles = fields_hash.fetch(:profiles, [])

      form_fields = if profiles.present?
                      profiles.collect { |profile|
                        fields = fields_hash.fetch(profile.to_sym, {})
                        content = []
                        content << @template.content_tag(:h3, I18n.t("profiles.#{profile}", default: profile), class: 'lead clearfix')
                        content << build_fields_for(decorator, fields)
                        content.join.html_safe
                      }.join.html_safe
                    else
                      build_fields_for(decorator, fields_hash)
                    end
      [form_fields, build_form_buttons].join.html_safe
    end

    def build_fields_for(decorator, fields)
      @template.content_tag(:ul, class: 'row list-unstyled') do
        fields.each do |field_name|
          options = decorator.try(:attribute_type_for, field_name, true) || {type: 'text_field', required: false}
          type = options.delete(:type)

          if self.respond_to?('admin_'.concat(type))
            concat(send('admin_'.concat(type), field_name, options))
          else
            concat admin_generic_field(type, field_name, options)
          end
        end
      end
    end

    def build_form_buttons
      lead = @template.content_tag(:h3, nil, class: 'lead clearfix')
      tags = @template.content_tag(:div, [submit_tag, ' ', reset_tag].join.html_safe, class: 'col-sm-12')
      lead.concat(@template.content_tag(:div, tags, class: 'row'))
    end

    def submit_tag
      tag_text = @template.content_tag(:i, nil, class: 'glyphicon glyphicon-check')
      tag_text.concat(@template.content_tag(:span, '提交'))
      @template.content_tag(:button, tag_text, class: 'btn btn-icon btn-info', type: 'submit')
    end

    def reset_tag
      tag_text = @template.content_tag(:i, nil, class: 'glyphicon glyphicon-repeat')
      tag_text.concat(@template.content_tag(:span, '重置'))
      @template.content_tag(:button, tag_text, class: 'btn btn-icon btn-warning', type: 'reset')
    end
  end
end
