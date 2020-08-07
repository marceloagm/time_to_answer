class CreateVerificarPagamentos < ActiveRecord::Migration[5.2]
  def change
    create_table :verificar_pagamentos do |t|
      t.string :reference_picpay
      t.string :equipe_picpay
      t.string :user_picpay

      t.timestamps
    end
  end
end
