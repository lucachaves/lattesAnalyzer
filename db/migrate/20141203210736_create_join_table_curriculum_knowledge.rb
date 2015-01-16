class CreateJoinTableCurriculumKnowledge < ActiveRecord::Migration
  def change
    create_join_table :curriculums, :knowledges do |t|
      # t.index [:curriculum_id, :knowledge_id]
      # t.index [:knowledge_id, :curriculum_id]
    end
  end
end
