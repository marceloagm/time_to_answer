class CreateStatusPagamentos < ActiveRecord::Migration[5.2]
  def change
    create_table :status_pagamentos do |t|
      t.references :equipe, foreign_key: true
      t.string :rodada
      t.string :status

      t.timestamps
    end
  end
end
