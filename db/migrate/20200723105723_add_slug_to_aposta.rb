class AddSlugToAposta < ActiveRecord::Migration[5.2]
  def change
    add_column :aposta, :slug, :string
  end
end
