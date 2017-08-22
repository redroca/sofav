require 'rails/generators/named_base'
require 'rails/generators/active_record'

module Sofa
  module Generators
    class SofaGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      include Sofa::Local

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
    end
  end
end
