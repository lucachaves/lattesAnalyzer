class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :id16
      t.string :id10
      t.string :name
      t.date :lattes_updated_at
      t.references :location, index: true

      t.timestamps
    end
    add_index :people, :id16, unique: true
    add_index :people, :id10, unique: true
  end
end
