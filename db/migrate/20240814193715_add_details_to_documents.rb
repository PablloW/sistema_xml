class AddDetailsToDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :documents, :serie, :string
    add_column :documents, :nNF, :string
    add_column :documents, :dhEmi, :datetime
    add_column :documents, :emit, :text
    add_column :documents, :dest, :text
    add_column :documents, :total_products, :decimal
    add_column :documents, :total_taxes, :decimal
  end
end
