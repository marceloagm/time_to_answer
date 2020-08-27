class CreateTesteIpns < ActiveRecord::Migration[5.2]
  def change
    create_table :teste_ipns do |t|
      t.string :ipn

      t.timestamps
    end
  end
end
