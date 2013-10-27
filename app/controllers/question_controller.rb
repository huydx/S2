class QuestionController < ApplicationController
  def index
    slide_id = params[:id]
    @questions = Question.where(slide_id: slide_id)
    
    @questions.sort! do |q1, q2|
      vote_q1 = $redis.get redis_vote_key_with_parms(slide_id, q1.id) 
      vote_q2 = $redis.get redis_vote_key_with_parms(slide_id, q2.id)
      vote_q2 <=> vote_q1
    end

    @slide_id = params[:id]
  end
  
  def create 
  end

  def vote
    @question = Question.find(params["question_id"])
    type = params["type"] || "up"
    unless already_voted?
      case type
      when "up"
        $redis.incr redis_vote_key
      when "down"
        $redis.decr redis_vote_key
      end
      $redis.set redis_user_voted_key, type
      render json: {"score" => $redis.get(redis_vote_key)}.to_json
    else 
      render nothing: true, status: 401
    end
  end
  
  private
  def redis_vote_key_with_parms(slide_id, question_id)
    "vote:"\
    "#{slide_id}:"\
    "#{question_id}"
  end

  def redis_vote_key
    "vote:"\
    "#{params['slide_id']}:"\
    "#{params['question_id']}"
  end

  def redis_user_voted_key
    "vote:"\
    "#{params['slide_id']}:"\
    "#{params['question_id']}:"\
    "#{current_user.username}"
  end

  def already_voted?
    $redis.get redis_user_voted_key
  end
end
