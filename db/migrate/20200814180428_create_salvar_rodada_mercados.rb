class CreateSalvarRodadaMercados < ActiveRecord::Migration[5.2]
  def change
    create_table :salvar_rodada_mercados do |t|
      t.string :rodada_atual
      t.string :rodada_anterior
      t.string :mercado
      t.string :dia
      t.string :mes
      t.string :hora
      t.string :minuto

      t.timestamps
    end
  end
end
