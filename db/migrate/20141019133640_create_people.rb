class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :id16
      t.string :name
      t.date :lattes_updated_at
      t.references :location, index: true
      t.references :knowlegde, index: true

      t.timestamps
    end
  end
end
