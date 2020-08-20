class AddMensagemToSalvarAtletumAnterior < ActiveRecord::Migration[5.2]
  def change
    add_column :salvar_atletum_anteriors, :mensagem, :text
  end
end
