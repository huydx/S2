class AddHostNameInAnswer < ActiveRecord::Migration
  def change
    add_column :questions, :host_name, :string
  end
end
