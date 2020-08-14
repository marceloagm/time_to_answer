class CreateAtletaPontuados < ActiveRecord::Migration[5.2]
  def change
    create_table :atleta_pontuados do |t|
      t.string :rodada
      t.longtext :atletas

      t.timestamps
    end
  end
end
