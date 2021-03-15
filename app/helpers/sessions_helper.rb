# frozen_string_literal: true

module SessionsHelper
  def change_organisation(organisation)
    session[:organisation_id] = organisation.id if organisation
  end

  def current_organisation
    change_organisation(active_organisations.last) if organisation? && session[:organisation_id].nil?
    Organisation.find_by(id: session[:organisation_id])
  end
  
  def admin_user?
    organisation_membership ||= OrganisationMembership.find_by(user_id: current_user.id, organisation_id: current_organisation.id)
    (current_user.id == current_organisation.owner_id) || organisation_membership&.is_admin
  end

  def session_symbol(name)
    path = request.fullpath.split('/')
    "#{path.second_to_last}_#{path.last}_#{name}"
  end
end