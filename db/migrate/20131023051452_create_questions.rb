class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :slide_id
      t.string :content
      t.string :ask_user
      t.string :host_user
      t.string :vote_up
      t.string :vote_down

      t.timestamps
    end
  end
end
