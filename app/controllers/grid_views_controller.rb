# frozen_string_literal: true

class GridViewsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_in_organisation!

  def index
    @grids = repo.all
  end

  def create
    @grid_view = repo.create(params[:grid_id])
    redirect_to edit_user_grid_view_path(current_user.id, @grid_view.id)
  end

  def edit
    @grid_view = repo.load(params[:id])
    @available_columns = repo.all_available_columns(params[:id])
  end

  def destroy
    repo.destroy(params[:id])

    redirect_to grid_views_path
  end

  private

  def repo
    @repo ||= GridViewRepository.new(current_organisation, current_user)
  end
end
