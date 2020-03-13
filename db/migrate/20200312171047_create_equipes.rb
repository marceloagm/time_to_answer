class CreateEquipes < ActiveRecord::Migration[5.2]
  def change
    create_table :equipes do |t|
      t.string :nome_time, null: false
      t.string :cartoleiro, null: false
      t.string :slug, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
