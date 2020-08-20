class AddMensagemToSalvarAtletum < ActiveRecord::Migration[5.2]
  def change
    add_column :salvar_atleta, :mensagem, :text
  end
end
