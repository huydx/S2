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
      Answer.create(content: params["answer-content"], question_id: question_id) :
      answer.update(content: params["answer-content"])
    render js: "location.reload();"
  end
end
