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
  end
end
