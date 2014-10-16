class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.date :updated
      t.references :location, index: true

      t.timestamps
    end
  end
end
