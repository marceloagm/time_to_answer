class AddEscudoToEquipe < ActiveRecord::Migration[5.2]
  def change
    add_column :equipes, :escudo, :text
  end
end
