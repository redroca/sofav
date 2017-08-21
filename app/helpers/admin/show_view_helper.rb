module Admin
  module ShowViewHelper
    delegate :model, to: :@template

    def build_view_for(attribute_name)
      fields_hash = decorator.try(attribute_name) || {}
      profiles = fields_hash.fetch(:profiles, [])

      form_fields = if profiles.present?
                      profiles.collect { |profile|
                        fields = fields_hash.fetch(profile.to_sym, {})
                        content = []
                        content << content_tag(:h3, I18n.t("profiles.#{profile}", default: profile), class: 'lead clearfix')
                        content << build_fields_for(decorator, fields)
                        content.join.html_safe
                      }.join.html_safe
                    else
                      build_fields_for(decorator, fields_hash)
                    end

      [build_action_buttons, form_fields].join.html_safe
    end

    def build_action_buttons
      edit_btn = Array(decorate.class.permitted_instance_methods_for(action_name)).collect { |action|
        render_to_string("actions/#{action}", locals: {record: decorate.object}, layout: false)
      }.join("\n").html_safe

      # edit_btn = link_to t('actions.edit'), [scope, record, action: 'edit'], class: 'btn btn-primary'
      content_tag(:div, edit_btn, class: 'pull-right')
    end

    def build_fields_for(decorator, fields)
      content_tag(:div, class: 'row detail-info clearfix') do
        content_tag(:ul, class: 'col-sm-12 col-md-12 list-unstyled') do
          fields.each do |field_name|
            options = decorator.try(:attribute_type_for, field_name, true) || {}
            concat(render_view(field_name, options))
          end
        end
      end
    end

    def render_view(method, options = {})
      field_wrapper(method, options) do
        decorate.human(method)
      end
    end

    def field_wrapper(method, options = {}, &block)
      label_options = options.extract!(:label_class, :required, :block)
      is_block = label_options[:block]
      options[:class] ||= 'form-control'
      options.merge!(id: '_form_id_'.concat(method))

      content_tag(:li, class: is_block ? 'col-sm-12 col-md-12' : 'col-sm-6 col-md-6') do
        content = [content_tag(:b, [model.human_attribute_name(method), ":"].join, default: method)]
        if is_block
          content << content_tag(:p, yield(block))
        else
          content << content_tag(:span, yield(block))
        end
        content.join.html_safe
      end

    end

  end
end
