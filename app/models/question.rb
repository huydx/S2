class Question < ActiveRecord::Base
  include Redis::Objects
  counter :vote_up
  counter :vote_down

  has_one :answer

  def vote_count
    vote_up.value - vote_down.value
  end

  def already_voted(user_name)
    key = "vote:"\
      "#{self.id}:"\
      "#{user_name}"
    $redis.get key
  end
end
