class AnswerController < ApplicationController
  layout false

  def index
    @question_id = params[:questionId].to_i
    @answer_content = Question.find(@question_id).answer.content rescue ""
  end

  def create; end
end
