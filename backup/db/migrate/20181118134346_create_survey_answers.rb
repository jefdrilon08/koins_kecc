class CreateSurveyAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_answers, id: :uuid do |t|
      t.references :survey, type: :uuid, foreign_key: true
      t.jsonb :meta
      t.jsonb :data
      t.string :status

      t.timestamps
    end
  end
end
