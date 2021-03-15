# frozen_string_literal: true

class OrganisationsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_is_owner, only: [:edit, :update]

  def create
    @organisation = Organisation.new(organisation_params)
    @organisation.user_id = current_user.id
    if @organisation.save
      OrganisationMembership.create(organisation_id: @organisation.id, user_id: current_user.id, is_admin: true)
      redirect_to root_path
    else
      render "new"
    end
  end

  def update
    if @organisation.update(organisation_params)
      redirect_to root_path
    else
      render "edit"
    end
  end

  def new
    @organisation = Organisation.new
  end

  def edit
    @organisation = Organisation.find_by(id: current_organisation.id) or not_found
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name)
  end

  def user_is_owner
    @organisation = Organisation.find_by(id: params[:id], user_id: current_user.id)
    redirect_to root_path unless @organisation
  end
end
