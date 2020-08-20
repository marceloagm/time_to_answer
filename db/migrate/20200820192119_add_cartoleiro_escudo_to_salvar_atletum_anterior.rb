class AddCartoleiroEscudoToSalvarAtletumAnterior < ActiveRecord::Migration[5.2]
  def change
    add_column :salvar_atletum_anteriors, :cartoleiro, :string
    add_column :salvar_atletum_anteriors, :escudo, :text
  end
end
