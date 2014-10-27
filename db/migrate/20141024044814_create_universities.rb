class CreateUniversities < ActiveRecord::Migration
  def change
    create_table :universities do |t|
      t.string :name
      t.string :abbr
      t.string :organ
      t.references :location, index: true

      t.timestamps
    end
  end
end
