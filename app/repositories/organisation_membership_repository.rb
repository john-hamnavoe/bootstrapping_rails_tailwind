# frozen_string_literal: true

class OrganisationMembershipRepository < ApplicationRepository
  def all(_args = {}, _params = nil)
    OrganisationMembership.includes(:user, :organisation).where(organisation: organisation)
  end

  def all_non_members
    query = User.joins("LEFT JOIN organisation_memberships ON users.id = organisation_memberships.user_id and organisation_memberships.organisation_id = #{organisation.id}").where("organisation_memberships.id is null")

    query = query.where("email LIKE :domain", domain: "%#{organisation.domain}%") if organisation.restrict_to_domain

    query
  end

  def create(params)
    organsiation_membership = OrganisationMembership.new(params)
    organsiation_membership.organisation = organisation
    organsiation_membership.save
    organsiation_membership
  end

  def update(id, params)
    organsiation_membership = OrganisationMembership.find_by(id: id, organisation: organisation)
    organsiation_membership&.update(params)
    organsiation_membership
  end

  def delete(id)
    organsiation_membership = OrganisationMembership.find_by(id: id, organisation: organisation)
    organsiation_membership&.delete
    organsiation_membership
  end

  def load(id)
    OrganisationMembership.find_by(id: id, organisation: organisation)
  end
end
