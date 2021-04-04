# frozen_string_literal: true

class OrganisationMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_in_organisation!
  before_action :user_organisation_admin!

  def index
    @organisation_memberships = repo.all
    @organisation_potential_memberships = repo.all_non_members
  end

  def create
    @organsiation_membership = repo.create(organisation_membership_params)

    redirect_to organisation_memberships_path
  end

  def update
    @organsiation_membership = repo.update(params[:id], organisation_membership_params)

    redirect_to organisation_memberships_path
  end

  def destroy
    organisation_membership = repo.load(params[:id])

    repo.delete(params[:id]) unless organisation_membership.user_id == current_organisation.owner_id

    redirect_to organisation_memberships_path
  end

  private

  def organisation_membership_params
    params.require(:organisation_membership).permit(:user_id, :is_admin)
  end

  def repo
    @repo ||= OrganisationMembershipRepository.new(current_organisation, current_user)
  end
end
