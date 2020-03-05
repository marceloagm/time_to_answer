class AddNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :nome, :string
    add_column :users, :sobrenome, :string
    add_column :users, :rg, :string
  end
end
