class CreateJoinTableStudentTeacher < ActiveRecord::Migration
  def change
    create_join_table :knowledges, :people do |t|
      # t.index [:knowledge_id, :person_id]
      # t.index [:person_id, :knowledge_id]
    end
  end
end
