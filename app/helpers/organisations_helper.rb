# frozen_string_literal: true

module OrganisationsHelper
  def active_organisations
    Organisation.eager_load(:organisation_memberships).where("(organisations.user_id = :current_user OR organisation_memberships.user_id = :current_user)", current_user: current_user.id) if user_signed_in?
  end

  def organisation?
    active_organisations.nil? ? false : active_organisations.count.positive?
  end

  def organisation_logo(organisation, size = 40)
    if organisation.logo.attached?
      organisation.logo.variant(resize_to_limit: [size, size])
    else
      image_path("hamnavoe_logo.png")
    end
  end
end
