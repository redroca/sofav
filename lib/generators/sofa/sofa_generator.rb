require 'rails/generators/named_base'
require 'rails/generators/active_record'

module Sofa
  module Generators
    class SofaGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      include Sofa::Local
      include Sofa::Decorator

      def create_model
        @agruments = "#{file_name}"

        attributes.each do |a|
          @agruments += " #{a.name}:#{a.type}"
        end

        generate "model", @agruments
      end

      def create_controller
        generate "controller", "Admin::#{file_name} --skip-routes"
      end

      def create_kaminari
         generate "kaminari:views", "default --views-prefix admin"
      end

      def create_locales_activerecord
        @record = Array.new
        attributes.each do |a|
          @record << a.name
        end

        create_config_record(file_name, @record)
      end
      
      def create_locales_attribute_types
        create_config_attribute(file_name, attributes)
      end

      def create_model_decorator
        create_decorator(file_name, class_name, attributes)
      end
    end
  end
end
