module Sofa
  module Decorator
    def create_decorator(file_name, class_name, attributes)
      @attr = ''

      attributes.each do |a|
        @attr += "#{a.name} "
      end

      create_file "app/decorator/#{file_name}_decorator.rb", <<-FILE
class #{class_name}Decorator < BaseDecorator
  include EnumerizeConcern

  #collection_search do
  #  {name: "q", search_in: [], placeholder: '', action: '/admin/', fuzzy: true}
  #end

  collection_attributes do
    ["#", ]
  end

  permitted_class_methods do
    {index: ["new"]}
  end

  permitted_instance_methods do
    {index: ["show", "edit", "destroy"], show: ["edit"]}
  end

  form_attributes do
    {
      profiles: %w{base_info},
      base_info: %w{#{@attr}}
    }
  end

  show_page_attributes do
    {
      profiles: %w{base_info},
      base_info: %w{#{@attr}}
    }
  end
end
      FILE
    end
  end
end