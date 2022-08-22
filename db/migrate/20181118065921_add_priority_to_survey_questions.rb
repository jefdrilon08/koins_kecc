class AddPriorityToSurveyQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_questions, :priority, :integer
  end
end
