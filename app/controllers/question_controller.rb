class QuestionController < ApplicationController
  before_action :set_up_api
  before_action :require_user, except: [:ask_post, :vote, :all]
  protect_from_forgery except: [:ask_post, :vote]

  def index
    api_instance = SlideShare::Base.new(
      api_key: ENV['API_KEY'], 
      shared_secret: ENV['SHARED_SECRET']
    )

    slide_id = params[:id]
    slide_info = api_instance.slideshows.find(slide_id)
    slide_owner = slide_info["Slideshow"]["Username"] rescue ""
    @editable = slide_owner == current_user.username
    @questions = all_questions_from_db(slide_id)
    
    @slide = @api_instance.slideshows.find(slide_id, detailed: true, with_image: true) rescue nil
  end

  def all
    questions = all_questions_from_db(params[:id])
    respond_to do |format|
      format.json { render json: make_questions_hash(questions) }
    end
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
    
    respond_to do |format|
      format.json { render json: {message_type: "sucess"} }
      format.html { render js: "$.colorbox.close()" }
      format.js { render js: "$.colorbox.close()" }
    end
  rescue Exception => e
    puts e
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
  def redis_vote_key_with_parms(question_id)
    "vote:"\
    "#{question_id}"
  end

  def redis_vote_key
    "vote:"\
    "#{params['question_id']}"
  end

  def redis_user_voted_key
    user_name = current_user.username.nil? ? 
      params["user_name"] :
      current_user.username

    "vote:"\
    "#{params['question_id']}:"\
    "#{user_name}"
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
    user_name = current_user.username rescue ""

    Question.create(
      slide_id: slide_id, 
      content: question_content,
      ask_user: user_name,
      slide_page_num: page_num
    )
  end

  def make_questions_hash(questions)
    questions.map do |question|
      { questionId: question.id,
        content: question.content,
        askUser: question.ask_user,
        pageNum: question.slide_page_num.to_i,
        voteNum: vote_count(question.slide_id, question.id) }
    end
  end

  def vote_count(slide_id, question_id)
    key = "vote:"\
    "#{question_id}"
    ($redis.get key) || 0
  end

  def all_questions_from_db(slide_id)
    questions = Question.where(slide_id: slide_id)

    if questions.length >= 2
      questions.sort! do |q1, q2|
        vote_q1 = $redis.get redis_vote_key_with_parms(q1.id)
        vote_q2 = $redis.get redis_vote_key_with_parms(q2.id)
        vote_q2.to_i <=> vote_q1.to_i
      end
    end
  end
end
