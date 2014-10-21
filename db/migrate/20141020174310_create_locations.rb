class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :city
      t.string :uf
      t.string :country
      t.string :country_abbr

      t.timestamps
    end
  end
end
