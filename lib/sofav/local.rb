require "yaml"

module Sofav
  module Local
    def create_config_record(file_name, record)
      record_config = YAML.load_file(File.join(__dir__, '../generators/sofav/templates/activerecord.zh-CN.yml'))
      
      record_config["zh-CN"]["activerecord"]["models"] = {"#{file_name}" => nil}
      record_config["zh-CN"]["activerecord"]["attributes"] = {"#{file_name}" => {"#{record.first}" => nil}}
      record.shift

      record.each do |a|
        record_config["zh-CN"]["activerecord"]["attributes"]["#{file_name}"][a] = nil
      end

      create_file "config/locales/activerecord/#{file_name}.zh-CN.yml", <<-FILE
#{record_config.to_yaml}
      FILE
    end

    def create_config_attribute(file_name, types)
      attributes_config = YAML.load_file(File.join(__dir__, '../generators/sofav/templates/attribute_types.zh-CN.yml'))
      attributes_config["zh-CN"]["attribute_types"] = {"#{file_name}" => {"#{types.first.name}" => nil}}

      types.each do |t|
        attributes_config["zh-CN"]["attribute_types"]["#{file_name}"]["#{t.name}"] = {"type" => nil}
        attributes_config["zh-CN"]["attribute_types"]["#{file_name}"]["#{t.name}"]["required"] = true
        attributes_config["zh-CN"]["attribute_types"]["#{file_name}"]["#{t.name}"]["type"] = type_field(t.type)
      end

      create_file "config/locales/attribute_types/#{file_name}.zh-CN.yml", <<-FILE
#{attributes_config.to_yaml}
      FILE
    end

    private
    def type_field(type)
      case type
      when 'integer', 'float'
        "number_field"
      when 'datetime'
        "datetime_select"
      when 'boolean'
        "collection_check_box"
      when 'date'
        "date_select"
      else
        "text_field"
      end
    end
  end
end