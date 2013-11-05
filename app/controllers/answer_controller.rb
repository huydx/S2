class AnswerController < ApplicationController
  layout false

  def index
    @question_id = params[:questionId].to_i
    @answer_content = Question.find(@question_id).answer.content rescue ""
  end

  def create
    question_id = params['question-id'].to_i
    answer = Question.find(question_id).answer

    answer = answer.nil? ? 
      Answer.create(content: params["question-content"]) :
      answer.update(content: params["question-content"])

    render js: "location.reload();"
  end
end
