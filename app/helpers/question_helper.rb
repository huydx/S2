module QuestionHelper
  def already_voted(slide_id, question_id)
    key = "vote:"\
      "#{slide_id}:"\
      "#{question_id}:"\
      "#{current_user.username}"
    $redis.get key
  end

  def vote_count(slide_id, question_id)
    key = "vote:"\
    "#{slide_id}:"\
    "#{question_id}"
    ($redis.get key) || 0
  end

  def vote_up_class(slide_id, question_id)
    already_voted(slide_id, question_id) == "up" ? "vote-up-on" : "vote-up-off"
  end

  def vote_down_class(slide_id, question_id)
    already_voted(slide_id, question_id) == "down" ? "vote-down-on" : "vote-down-off"
  end
end
