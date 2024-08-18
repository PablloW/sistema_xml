require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:user) }
  it { should have_one_attached(:file) }
  it { should have_many(:products) }
  it { should have_many(:taxes) }

  # Exemplo de teste de validação
  it "is invalid without a user" do
    document = Document.new(user: nil)
    expect(document).to_not be_valid
  end
end
