class QuestionController < ApplicationController
  def index
    @questions = Question.where(slide_id: params[:id])
  end

  def vote
    type = params[:type] || 0
    score = type == 'up' ? type.to_i : (-type.to_i)
  end
end
