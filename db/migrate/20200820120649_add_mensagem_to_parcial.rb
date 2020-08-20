class AddMensagemToParcial < ActiveRecord::Migration[5.2]
  def change
    add_column :parcials, :mensagem, :text
  end
end
