class CreateCurriculums < ActiveRecord::Migration
  def change
    create_table :curriculums do |t|
      t.string :id16
      t.string :id10
      t.date :lattes_updated_at
      t.string :scholarship
      t.string :degree
      t.xml :xml

      t.timestamps
    end
    add_index :curriculums, :id10, unique: true
  end
end
