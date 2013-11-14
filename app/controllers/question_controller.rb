class QuestionController < ApplicationController
  before_action :set_up_api

  def index
    api_instance = SlideShare::Base.new(
      api_key: ENV['API_KEY'], 
      shared_secret: ENV['SHARED_SECRET']
    )

    slide_id = params[:id]
    slide_info = api_instance.slideshows.find(slide_id)
    slide_owner = slide_info["Slideshow"]["Username"] rescue ""

    @questions = Question.where(slide_id: slide_id)
    @editable = slide_owner == current_user.username

    if @questions.length >= 2
      @questions.sort! do |q1, q2|
        vote_q1 = $redis.get redis_vote_key_with_parms(slide_id, q1.id)
        vote_q2 = $redis.get redis_vote_key_with_parms(slide_id, q2.id)
        vote_q2.to_i <=> vote_q1.to_i
      end
    end
    @slide = @api_instance.slideshows.find(slide_id, detailed: true, with_image: true) rescue nil
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
    @slide_page_num = params['slidePageNum']
    render layout: false
  end

  def ask_post
    question_payload = make_question_payload
    channel = make_channel(params['slide-id'])    
    slide_page_num = params['slide-page-num']    
    
    unless params['question-content'].blank?
      save_db
      broadcast(channel, question_payload)
    end

    render js: "$.colorbox.close()"
  rescue Exception => e
    binding.pry
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

  def make_question_payload
    content = params['question-content']
    page_num = params['slide-page-num'].to_i
    ask_user_name = current_user.username rescue ""

    {
     'messageType' => 'question',
     'messageOwner' => ask_user_name,
     'messageExtra' => 
     {
        'content' => content,
        'title' => '',
        'pageNum' => page_num
     }
    }
  end
  
  def make_channel(slide_id)
    host_name = $redis.get("streaming:#{slide_id}")
    host_name[0] == "/" ? host_name : "/#{host_name}"
  end

  def event_server
    "#{ENV['EVENT_SERVER']}faye"
  end

  def save_db
    slide_id, question_content, page_num = 
      params['slide-id'], params['question-content'], params['slide-page-num'].to_i

    Question.create(
      slide_id: slide_id, 
      content: question_content,
      ask_user: current_user.username,
      slide_page_num: page_num
    )
  end
end
