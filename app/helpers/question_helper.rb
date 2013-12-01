module QuestionHelper
  def already_voted(question)
    question.already_voted(current_user.username)
  end

  def vote_up_class(question)
    already_voted(question) == "up" ? "vote-up-on" : "vote-up-off"
  end

  def vote_down_class(question)
    already_voted(question) == "down" ? "vote-down-on" : "vote-down-off"
  end
end
