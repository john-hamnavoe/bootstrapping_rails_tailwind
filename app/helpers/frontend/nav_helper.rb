module Frontend
  module NavHelper

  def nav_link_class(root, active_color)
    if request.path.start_with?(*root)
      active_class(active_color)
    else
      non_active_class(active_color)
    end
  end

  private

    def non_active_class(active_color)
      "block lg:inline-block py-1 md:py-3 mr-2 pl-1 align-middle text-gray-600 no-underline hover:text-gray-900 border-b-2 border-white hover:border-#{active_color}"
    end

    def active_class(active_color)
      "block lg:inline-block py-1 md:py-3 mr-2 pl-1 align-middle text-#{active_color} no-underline hover:text-gray-900 border-b-2 border-#{active_color} hover:border-#{active_color}"
    end
  end
end