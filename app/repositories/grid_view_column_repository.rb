# frozen_string_literal: true

class GridViewColumnRepository < ApplicationRepository
  def create(params)
    grid_view_column = GridViewColumn.new(params)
    grid_view_column.save
    grid_view_column
  end

  def delete(id)
    grid_view_column = GridViewColumn.find_by(id: id)
    grid_view_column.remove_from_list
    grid_view_column&.destroy
    grid_view_column
  end

  def move(id, position)
    grid_view_column = GridViewColumn.find_by(id: id)
    grid_view_column.insert_at(position)
    grid_view_column
  end
end
