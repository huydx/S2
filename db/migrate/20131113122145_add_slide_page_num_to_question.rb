class AddSlidePageNumToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :slide_page_num, :integer
  end
end
