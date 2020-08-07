class CreateVerificarPagamentoMps < ActiveRecord::Migration[5.2]
  def change
    create_table :verificar_pagamento_mps do |t|
      t.string :reference_mp
      t.string :equipe_mp
      t.string :user_mp
      t.string :rodada

      t.timestamps
    end
  end
end
