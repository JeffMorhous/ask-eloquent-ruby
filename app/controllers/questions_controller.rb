class QuestionsController < ApplicationController
  def ask
    question = params[:question] # TODO: Strong Params
    answer = question_service.answer(question)
    render json: { response: answer }
  end

  private

  def question_service
    @question_service ||= QuestionService.new
  end
end
