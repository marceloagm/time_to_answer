class AddAnoToSalvarRodadaMercado < ActiveRecord::Migration[5.2]
  def change
    add_column :salvar_rodada_mercados, :ano, :string
  end
end
