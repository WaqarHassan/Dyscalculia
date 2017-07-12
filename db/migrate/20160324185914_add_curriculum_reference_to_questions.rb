class AddCurriculumReferenceToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :curriculum_reference, :string
  end
end
