class CreateApostaStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :aposta_statistics do |t|
      t.string :rodada
      t.integer :total, default: 0

      t.timestamps
    end
  end
end
