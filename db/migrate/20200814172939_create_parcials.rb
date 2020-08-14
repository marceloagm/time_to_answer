class CreateParcials < ActiveRecord::Migration[5.2]
  def change
    create_table :parcials do |t|
      t.string :slug
      t.string :rodada
      t.string :pontos
      t.string :pontos_atleta
      t.string :atletas
      t.string :capitao
      t.string :nome_atleta
      t.string :posicao_atleta
      t.longtext :foto_final
      t.string :equipe_nome

      t.timestamps
    end
  end
end
