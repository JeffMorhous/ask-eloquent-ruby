class UpdateQuestionTextOnQuestions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :questions, :question_text, false
    add_index :questions, :question_text, unique: true
  end
end
