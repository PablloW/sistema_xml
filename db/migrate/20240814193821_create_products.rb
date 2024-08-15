class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :ncm
      t.string :cfop
      t.string :uCom
      t.decimal :qCom
      t.decimal :vUnCom
      t.references :document, null: false, foreign_key: true

      t.timestamps
    end
  end
end
