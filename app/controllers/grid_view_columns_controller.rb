# frozen_string_literal: true

class GridViewColumnsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_in_organisation!

  def create
    @grid_view_column = repo.create(grid_view_column_params)

    redirect_to edit_user_grid_view_path(current_user.id, @grid_view_column.grid_view_id)
  end

  def move
    repo.move(params[:id], params[:position].to_i)
  end

  def destroy
    @grid_view_column = repo.delete(params[:id])

    redirect_to edit_user_grid_view_path(current_user.id, @grid_view_column.grid_view_id)
  end

  private

  def grid_view_column_params
    params.require(:grid_view_column).permit(:grid_view_id, :column_id)
  end

  def repo
    @repo ||= GridViewColumnRepository.new(current_organisation, current_user)
  end
end
