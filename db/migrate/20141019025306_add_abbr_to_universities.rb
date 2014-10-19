class AddAbbrToUniversities < ActiveRecord::Migration
  def change
  	add_column :universities, :abbr, :string
  end
end
