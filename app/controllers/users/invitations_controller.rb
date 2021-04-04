# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  before_action :update_sanitized_params, only: :update

  def create
    self.resource = User.invite!(invite_params, current_user)
    resource_invited = resource.errors.empty?
    if resource_invited
      organistion_membership = OrganisationMembership.new(organisation: current_organisation, user: resource)
      organistion_membership.save
    end

    if resource_invited
      redirect_to organisation_memberships_path
    else
      respond_with_navigational(resource) { render "new" }
    end
  end

  def update
    super
  end

  protected

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name, :password, :password_confirmation, :invitation_token, :avatar, :avatar_cache])
  end
end
