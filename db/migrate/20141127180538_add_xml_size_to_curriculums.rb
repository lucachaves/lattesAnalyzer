class AddXmlSizeToCurriculums < ActiveRecord::Migration
  def change
  	add_column :curriculums, :xml_size, :integer
  end
end
