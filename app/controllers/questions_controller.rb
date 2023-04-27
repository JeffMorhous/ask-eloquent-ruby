class QuestionsController < ApplicationController
  def ask
    question = question_params
    answer = question_service.answer(question)
    render json: { response: answer }
  end

  private

  def question_service
    @question_service ||= QuestionService.new
  end

  def question_params
    params.require(:question)
  end
end
