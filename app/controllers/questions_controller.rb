class QuestionsController < ApplicationController
  def ask
    question = params[:question] # TODO: Strong Params
    question_answerer = QuestionAnswerer.new(question)
    answer = question_answerer.answer_question
    render json: { response: answer }
  end
end
