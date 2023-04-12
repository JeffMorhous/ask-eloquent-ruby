class QuestionsController < ApplicationController
  def ask
    question = params[:question]
    render json: { response: "Eventually I will answer: #{question}" }
  end
end
