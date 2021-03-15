# frozen_string_literal: true

module Frontend
  module PagyHelper
    include Pagy::Frontend
    # rubocop:disable Rails/HelperInstanceVariable
    def column_css(column_name)
      return "text-gray-900" if column_name.to_s == @order_by

      ""
    end

    def arrow(column_name)
      return if column_name.to_s != @order_by

      @direction == "desc" ? "↓" : "↑"
    end

    def arrow_css_down(column_name)
      return if column_name.to_s != @order_by

      @direction == "desc" ? "text-blue-900" : ""
    end

    def arrow_css_up(column_name)
      return if column_name.to_s != @order_by

      @direction == "asc" ? "text-blue-900" : ""
    end

    def direction
      @direction == "asc" ? "desc" : "asc"
    end

    def pagy_get_params(params)
      params.merge query: @query, order_by: @order_by, direction: @direction
    end

    def prev_page
      @pagy.prev || 1
    end

    def next_page
      @pagy.next || @pagy.last
    end
    # rubocop:enable Rails/HelperInstanceVariable
  end
end
