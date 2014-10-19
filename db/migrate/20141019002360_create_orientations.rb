class CreateOrientations < ActiveRecord::Migration
  def change
    create_table :orientations do |t|
      t.string :doc
      t.string :title
      t.string :kind
      t.string :formation
      t.string :year
      t.string :language
      t.string :orientation
      t.string :student
      t.references :course, index: true
      t.references :knowledge, index: true
      t.references :person, index: true

      t.timestamps
    end
  end
end
