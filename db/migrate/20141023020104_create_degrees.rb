class CreateDegrees < ActiveRecord::Migration
  def change
    create_table :degrees do |t|
      t.string :name
      t.string :title
      t.integer :year
      t.references :course, index: true
      t.references :person, index: true

      t.timestamps
    end
  end
end
