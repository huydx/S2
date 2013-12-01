class QuestionController < ApplicationController
  before_action :set_up_api
  before_action :require_user, except: [:create, :vote, :all]
  protect_from_forgery except: [:create, :vote]

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
  
  def create
    channel = make_channel(params['slide-id'])    
    slide_page_num = params['slide-page-num']    
    
    unless params['question-content'].blank?
      saved_question = save_db
      question_payload = make_question_payload(saved_question)
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

  def vote
    @question = Question.find(params["question_id"])
    type = params["type"] || "up"
    unless already_voted?
      case type
      when "up"; @question.vote_up.increment;
      when "down"; @question.vote_down.increment;
      end

      channel = make_channel(params['slide_id'])
      notify_payload = make_notify_payload({has_vote: true})
      broadcast(channel, notify_payload)

      $redis.set redis_user_voted_key, type
      render json: {"score" => @question.vote_count}.to_json
    else 
      render nothing: true, status: 422
    end
  end 

  def ask_page
    @slide_id = params['slideId']
    @slide_page_num = params['slidePageNum']
    render layout: false
  end

  private
  def redis_user_voted_key(question_id=nil)
    user_name = current_user.nil? ? 
      params["user_name"] :
      current_user.username
    
    question_id = question_id.nil? ? params['question_id'] : question_id
    "vote:"\
    "#{question_id}:"\
    "#{user_name}"
  end

  def already_voted?(question_id=nil)
    $redis.get redis_user_voted_key(question_id)
  end

  def broadcast(channel, payload)
    mes = {:channel => channel, data: payload}
    uri = URI.parse(event_server)
    Net::HTTP.post_form(uri, message: mes.to_json)
  end

  def make_question_payload(question)
    {'messageType' => 'question',
     'messageOwner' => question.ask_user,
     'messageExtra' => 
        { questionId: question.id,
          content: question.content,
          askUser: question.ask_user,
          pageNum: question.slide_page_num.to_i,
          voteNum: question.vote_count,
          alreadyVoted: 0 }
    }
  end

  def make_notify_payload(options={})
    {'messageType' => 'notify',
     'messageOwner' => current_user.username,
     'messageExtra' => options}
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
      voted = case already_voted?(question.id)
              when "up"; 1
              when "down"; -1
              else; 0
              end

      { questionId: question.id,
        content: question.content,
        askUser: question.ask_user,
        pageNum: question.slide_page_num.to_i,
        voteNum: question.vote_count,
        alreadyVoted: voted }
    end
  end

  def all_questions_from_db(slide_id)
    questions = Question.where(slide_id: slide_id)

    if questions.length >= 2
      questions.sort! do |q1, q2|
        vote_q1 = q1.vote_count 
        vote_q2 = q2.vote_count 
        vote_q2.to_i <=> vote_q1.to_i
      end
    end

    questions = questions.empty? ? [] : questions
  end
end
