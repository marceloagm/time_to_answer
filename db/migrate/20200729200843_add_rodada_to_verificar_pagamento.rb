class AddRodadaToVerificarPagamento < ActiveRecord::Migration[5.2]
  def change
    add_column :verificar_pagamentos, :rodada, :string
  end
end
