class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :orientations, :documentation, :document
  end
end
