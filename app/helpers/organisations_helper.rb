# frozen_string_literal: true

module OrganisationsHelper
  def organisation_logo(organisation, size = 40)
    if organisation.logo.attached?
      organisation.logo.variant(resize_to_limit: [size, size])
    else
      image_path("hamnavoe_logo.png")
    end
  end
end
