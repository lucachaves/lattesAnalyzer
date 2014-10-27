class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.date :lattes_updated_at
      t.references :curriculum, index: true

      t.timestamps
    end
    add_index :updates, :lattes_updated_at, unique: true
  end
end
