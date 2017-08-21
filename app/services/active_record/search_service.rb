module ActiveRecord
  class SearchService
    class Search
      attr_reader :search_in, :param_key, :fuzzy, :value

      def initialize(params, search)
        @search_in = search[:in] || []
        @param_key = search[:param_key]
        @fuzzy = search[:fuzzy]
        @value = params.delete(param_key)
      end

      def apply(relation)
        return relation if value.blank?

        values = []
        if fuzzy
          query = search_in.collect do |attr|
            # if attr.include? '.'
            #   relation = relation.joins(attr.split('.').first.singularize)
            # end

            if relation.model.columns_hash[attr]&.array
              values << value.to_s.downcase
              "? = ANY (#{attr})"
            else
              values << "%#{value.to_s.downcase}%"
              "#{attr} iLIKE ?"
            end
          end.join(' OR ')
        else
          query = search_in.collect do |attr|
            # if attr.include? '.'
            #   relation = relation.joins(attr.split('.').first.singularize)
            # end

            if relation.model.columns_hash[attr]&.array
              "? = ANY (#{attr})"
            else
              "lower(#{attr}) = ?"
            end
          end.join(' OR ')
          values = [value.to_s.downcase] * search_in.count
        end

        relation.where(query, *values)
      end
    end

    class Filter
      attr_reader :filters

      def initialize(filters)
        @filters = filters
      end

      def apply(relation)
        filters.present? ? relation.where(filters) : relation
      end
    end

    class Order
      attr_reader :attribute, :direction, :order_str

      def initialize(attribute, direction, order_str)
        @attribute = attribute
        @direction = direction
        @order_str = order_str
      end

      def apply(relation)
        if order_str.present?
          relation.order(order_str)
        elsif attribute.present?
          relation.order(attribute => direction)
        else
          relation
        end
      end
    end

    class Paginate
      attr_reader :page, :per_page

      def initialize(page, per_page)
        @page = page
        @per_page = per_page
      end

      def apply(relation)
        relation.page(page).per(per_page)
      end
    end

    attr_reader :model, :params, :options, :search, :filters, :order, :paginate

    def initialize(model, original_params, options = {})
      @model = model
      @params = original_params.deep_dup.with_indifferent_access
      @options = options

      _order_str = options.delete(:order_str) || params.delete(:order_str)
      _order = options.delete(:order) || params.delete(:order) || 'id'
      _direction = options.delete(:direction) || params.delete(:direction) || 'desc'
      _per_page = options.delete(:per_page) || params.delete(:per_page)

      @search = Search.new(params, options.delete(:search) || {})
      @filters = Filter.new(params.delete(:filters) || {})
      @order = Order.new(_order, _direction, _order_str)
      @paginate = Paginate.new(params.delete(:page), _per_page)
    end

    def run
      resources = model.where(params.slice(*model.column_names.collect(&:to_sym))).where(options)
      [search, filters, order, paginate].each do |operation|
        resources = operation.apply(resources)
      end
      resources
    end
  end
end
