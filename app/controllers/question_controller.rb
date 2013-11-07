class QuestionController < ApplicationController
  def index
    slide_id = params[:id]
    @questions = Question.where(slide_id: slide_id)
    if @questions.length >= 2
      @questions.sort! do |q1, q2|
        vote_q1 = $redis.get redis_vote_key_with_parms(slide_id, q1.id)
        vote_q2 = $redis.get redis_vote_key_with_parms(slide_id, q2.id)
        vote_q2.to_i <=> vote_q1.to_i
      end
    end

    @slide_id = params[:id]
  end
  
  def create; end

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

  def ask_page
    @slide_id = params['slideId']
    render layout: false
  end

  def ask_post
    question_payload = make_question_payload(params['question-content']) 
    channel = make_channel(params['slide-id'])    
    
    save_db(params['slide-id'], params['question-content'])
    broadcast(channel, question_payload)

    render js: "$.colorbox.close()"
  rescue Exception
    render nothing: true
  end
  
  def add_answer
    question_id = params['question-id'].to_i
    answer = Question.find(question_id).answer

    answer = answer.nil? ? 
      Answer.create(content: params["answer-content"], question_id: question_id) :
      answer.update(content: params["answer-content"])
    render js: "location.reload();"
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

  def broadcast(channel, payload)
    mes = {:channel => channel, data: payload}
    uri = URI.parse(event_server)
    Net::HTTP.post_form(uri, message: mes.to_json)
  end

  def make_question_payload(content)
    {
     'messageType' => 'question',
     'messageOwner' => current_user.username,
     'messageExtra' => 
     {
        'content' => content,
        'title' => ''
     }
    }
  end
  
  def make_channel(slide_id)
    host_name = $redis.get("streaming:#{slide_id}")
    "/#{host_name}"
  end

  def event_server
    "#{ENV['EVENT_SERVER']}faye"
  end

  def save_db(slide_id, question_content)
    Question.create(
      slide_id: slide_id, 
      content: question_content,
      ask_user: current_user.username
    )
  end
end
