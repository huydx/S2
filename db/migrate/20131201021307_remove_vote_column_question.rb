class RemoveVoteColumnQuestion < ActiveRecord::Migration
  def change
    remove_column :questions, :vote_up
    remove_column :questions, :vote_down
  end
end
