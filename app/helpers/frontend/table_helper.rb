# frozen_string_literal: true

module Frontend
  module TableHelper
    def table_wrapper(&block)
      content_tag(:div, nil, class: 'table-responsive', &block)
    end

    def table(add_class: nil, &block)
      table_wrapper do
        content_tag(:table, nil, class: "min-w-full divide-y divide-gray-200 #{add_class}", &block)
      end
    end
    # rounded-t-lg m-5 w-full mx-auto bg-gray-200 text-gray-800
    def hover_table(add_class: nil, &block)
      content_tag(:table, nil, class: "rounded-t-lg min-w-full divide-y divide-gray-200 hover:bg-gray-100 #{add_class}", &block)
    end

    def table_head(add_class: nil, bg_color: "bg-gray-50", &block)
      content_tag(:thead, nil, class: "#{bg_color} #{add_class}", &block)
    end

    def table_body(add_class: nil, data: nil, id: nil, &block)
      content_tag(:tbody, nil, class: "bg-white divide-y divide-gray-200 #{add_class}", data: data, id: id, &block)
    end

    def table_footer(add_class: nil, &block)
      content_tag(:tfoot, nil, class: add_class, &block)
    end

    def table_row(add_class: nil, title: nil, data: nil, id: nil, href: nil, &block)
      content_tag(:tr, nil, data: data, class: add_class, title: title, id: id, href: href, &block)
    end

    def table_row_controller(controller, add_class: nil, &block)
      content_tag(:tr, nil, class: add_class, data: { controller: controller }, &block)
    end

    def table_data(value = nil, add_class: nil, colspan: nil, data: nil, title: nil, id: nil, nowrap: true, &block)
      content_tag(:td, nil, nowrap: nowrap, colspan: colspan, data: data, title: title, class: "whitespace-nowrap", id: id) do
        content_tag(:p, value, class: "text-sm text-left font-medium text-gray-800 tracking-normal #{add_class}", &block)
      end
    end

    def table_compact_data(value = nil, add_class: nil, colspan: nil, data: nil, title: nil, id: nil, nowrap: true, &block)
      content_tag(:td, nil, nowrap: nowrap, colspan: colspan, data: data, title: title, class: "whitespace-nowrap", id: id) do
        content_tag(:p, value, class: "text-xxs text-left font-medium text-gray-800 tracking-tight #{add_class}", &block)
      end
    end

    def table_check_box_data(value = nil, add_class: nil, add_style: nil, colspan: nil, data: nil, title: nil, &block)
      content_tag(:td, nil, colspan: colspan, data: data, title: title, class: "#{add_class}", style: add_style) do
        content_tag(:i, nil, class: "fas fa-check-circle text-blue-500", &block) if value
      end
    end

    def table_status_data(checked = nil, actual = nil, add_class: nil, add_style: nil, colspan: nil, data: nil, title: nil, &block)
      icon_class = if checked && actual.zero?
                     'fas fa-times-circle text-yellow-400'
                   elsif checked && actual.positive?
                     'fas fa-check-circle text-green-500'
                   else
                     'fas fa-question-circle text-red-500'
                   end
      content_tag(:td, nil, colspan: colspan, data: data, title: title, class: "text-lg text-center #{add_class}", style: add_style) do
        content_tag(:i, nil, class: icon_class, &block)
      end
    end

    def table_column_compact(value = nil, add_class: nil, add_style: nil, colspan: nil, nowrap: true, &block)
      content_tag(:th, value, nowrap: nowrap, colspan: colspan, class: "py-1 text-xs text-left font-medium text-gray-500 tracking-tight #{add_class}", style: add_style, scope: 'col', &block)
    end

    def table_column(value = nil, add_class: nil, add_style: nil, colspan: nil, nowrap: true, &block)
      content_tag(:th, value, nowrap: nowrap, colspan: colspan, class: "py-1 px-1 text-left font-medium text-gray-500 #{add_class}", style: add_style, scope: 'col', &block)
    end

    def pagination_wrapper(add_class: nil, &block)
      content_tag(:div, nil, class: "bg-light d-flex justify-content-between align-items-center pl-1 pr-4 py-2 #{add_class}", &block)
    end

    def sortable_tr(column, reflex, title = nil, add_style: nil, add_class: nil)
      title ||= column.titleize
      render '/shared/sortable_tr', title: title, reflex: reflex, column: column, add_style: add_style, add_class: add_class
    end

    def sortable_tr_compact(column, reflex, title = nil, add_style: nil, add_class: nil)
      title ||= column.titleize
      render '/shared/sortable_tr_compact', title: title, reflex: reflex, column: column, add_style: add_style, add_class: add_class
    end    
  end
end
