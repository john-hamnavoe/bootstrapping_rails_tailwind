# frozen_string_literal: true

class ColumnRepository < ApplicationRepository
  def all_by_grid(grid_id)
    if GridView.where(user_id: user.id, grid_id: grid_id).exists?
      UserGridViewColumn.where(grid_id: grid_id, user_id: user.id).order(:position)
    else
      Column.where(grid_id: grid_id, default_on: true).order(:default_position)
    end
  end

  def sortable_columns_by_grid(grid_id)
    Column.where(grid_id: grid_id, sortable: true).map(&:name)
  end
end
