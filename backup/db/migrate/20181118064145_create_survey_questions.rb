class CreateSurveyQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_questions, id: :uuid do |t|
      t.references :survey, type: :uuid, foreign_key: true
      t.string :content
      t.string :question_type
      t.jsonb :data

      t.timestamps
    end
  end
end
