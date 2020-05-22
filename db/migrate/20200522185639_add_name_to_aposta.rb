class AddNameToAposta < ActiveRecord::Migration[5.2]
  def change
    add_column :aposta, :equipe_nome, :string
  end
end
