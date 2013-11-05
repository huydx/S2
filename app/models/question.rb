class Question < ActiveRecord::Base
  has_one :answer

  def vote_count
    vote_up - vote_down
  end
end
