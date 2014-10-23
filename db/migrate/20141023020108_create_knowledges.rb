class CreateKnowledges < ActiveRecord::Migration
  def change
    create_table :knowledges do |t|
      t.string :major_subject
      t.string :subject
      t.string :subsection
      t.string :specialty

      t.timestamps
    end
  end
end
