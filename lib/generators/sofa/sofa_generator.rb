require 'rails/generators/named_base'
require 'rails/generators/active_record'

module Sofa
  module Generators
    class SofaGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      include Sofa::Local

      # def create_model
      #   @agruments = "#{file_name}"
      #   attributes.each do |a|
      #     @agruments += " #{a.name}:#{a.type}"
      #   end

      #   generate "model", @agruments
      # end

      # def create_controller
      #   generate "controller", "Admin::#{file_name} --skip-routes"
      # end

      # def create_kaminari
      #   generate "kaminari:views", "default --views-prefix admin"
      # end

      def create_locales_activerecord
        @record = Array.new

        attributes.each do |a|
          @record << a.name
        end

        create_config_record(file_name, @record)
      end
      
      def create_locales_attribute_types
#         @types = 
# "zh-CN:
#   attribute_types:
#     #{plural_name.singularize}:"
        
#         attributes.each do |a|
#           case a.type
#           when 'integer', 'float'
#             @types += "\n\t\t\t#{a.name}:\n\t\t\t\ttype: 'number_field',\n\t\t\t\trequired: true"
#           when 'datetime'
#             @types += "\n\t\t\t#{a.name}:\n\t\t\t\ttype: 'datetime_select',\n\t\t\t\trequired: true"
#           when 'boolean'
#             @types += "\n\t\t\t#{a.name}:\n\t\t\t\ttype: 'collection_check_boxes',\n\t\t\t\trequired: true"
#           when 'date'
#             @types += "\n\t\t\t#{a.name}:\n\t\t\t\ttype: 'date_select',\n\t\t\t\trequired: true"
#           else
#             @types += "\n\t\t\t#{a.name}:\n\t\t\t\ttype: 'text_field',\n\t\t\t\trequired: true"
#           end
#         end

#         create_file "config/locales/attribute_types/#{file_name}.zh-CN.yml", <<-FILE
# #{@types}
#         FILE

        create_config_attribute(file_name, attributes)
      end
    end
  end
end
