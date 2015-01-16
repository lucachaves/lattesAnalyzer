class AddOrientationToCurriculums < ActiveRecord::Migration
  def change
  	add_column :curriculums, :orientation, :string
  end
end
