# frozen_string_literal: true

class GridViewRepository < ApplicationRepository
  def all
    Grid.all.order(:id)
  end

  def all_available_columns(id)
    grid_view = GridView.eager_load(:grid_view_columns).find_by(id: id, user_id: user.id)
    Column.where(grid_id: grid_view.grid_id).where.not(id: grid_view.grid_view_columns.pluck(:column_id))
  end

  def create(grid_id)
    grid_view = GridView.find_by(grid_id: grid_id, user_id: user.id)

    unless grid_view
      columns = Column.where(grid_id: grid_id, default_on: true).order(:default_position)
      grid_view = GridView.new(grid_id: grid_id, user_id: user.id, name: "Custom")
      columns.each do |c|
        grid_view.grid_view_columns.new(column_id: c.id)
      end
      grid_view.save
    end

    grid_view
  end

  def destroy(id)
    grid_view = GridView.find_by(id: id, user_id: user.id)
    grid_view&.destroy
    grid_view
  end

  def load(id)
    GridView.eager_load(:grid).eager_load(grid_view_columns: [:column]).find_by(id: id, user_id: user.id)
  end
end
