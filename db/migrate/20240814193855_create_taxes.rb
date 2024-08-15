class CreateTaxes < ActiveRecord::Migration[7.1]
  def change
    create_table :taxes do |t|
      t.decimal :icms
      t.decimal :ipi
      t.decimal :pis
      t.decimal :cofins
      t.references :document, null: false, foreign_key: true

      t.timestamps
    end
  end
end
