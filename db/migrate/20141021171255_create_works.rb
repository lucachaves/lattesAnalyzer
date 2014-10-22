class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :organ
      t.references :person, index: true
      t.references :university, index: true

      t.timestamps
    end
  end
end
