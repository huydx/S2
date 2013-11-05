class ChangeVoteUpFormatInQuestion < ActiveRecord::Migration
  def change
    change_column :questions, :vote_up, :integer
    change_column :questions, :vote_down, :integer
  end
end
