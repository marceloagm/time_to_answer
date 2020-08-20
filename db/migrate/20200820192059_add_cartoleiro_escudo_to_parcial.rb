class AddCartoleiroEscudoToParcial < ActiveRecord::Migration[5.2]
  def change
    add_column :parcials, :cartoleiro, :string
    add_column :parcials, :escudo, :text
  end
end
