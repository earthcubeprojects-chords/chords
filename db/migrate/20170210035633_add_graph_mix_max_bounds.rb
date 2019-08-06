class AddGraphMixMaxBounds < ActiveRecord::Migration[5.1]
  def change
    add_column :vars, :minimum_plot_value, :float
    add_column :vars, :maximum_plot_value, :float
  end
end
