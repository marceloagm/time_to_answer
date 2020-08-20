class AddCartoleiroEscudoToSalvarAtletum < ActiveRecord::Migration[5.2]
  def change
    add_column :salvar_atleta, :cartoleiro, :string
    add_column :salvar_atleta, :escudo, :text
  end
end
