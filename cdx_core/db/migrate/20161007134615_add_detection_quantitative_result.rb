class AddDetectionQuantitativeResult < ActiveRecord::Migration
  def change
    add_column :notifications, :detection_quantitative_result, :string
  end
end
