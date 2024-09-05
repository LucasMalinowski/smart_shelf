# Categorias
categories = {
  "Frutas" => [
    { name: "Maçã", quantity: 0, purchase_date: Date.today },
    { name: "Banana", quantity: 0, purchase_date: Date.today },
    { name: "Laranja", quantity: 0, purchase_date: Date.today },
    { name: "Uvas", quantity: 0, purchase_date: Date.today },
    { name: "Morango", quantity: 0, purchase_date: Date.today },
    { name: "Abacaxi", quantity: 0, purchase_date: Date.today }
  ],
  "Vegetais" => [
    { name: "Cenoura", quantity: 0, purchase_date: Date.today },
    { name: "Brócolis", quantity: 0, purchase_date: Date.today },
    { name: "Espinafre", quantity: 0, purchase_date: Date.today },
    { name: "Batata", quantity: 0, purchase_date: Date.today },
    { name: "Tomate", quantity: 0, purchase_date: Date.today },
    { name: "Cebola", quantity: 0, purchase_date: Date.today },
    { name: "Pimentão", quantity: 0, purchase_date: Date.today },
    { name: "Alho", quantity: 0, purchase_date: Date.today }
  ],
  "Laticínios" => [
    { name: "Leite", quantity: 0, purchase_date: Date.today },
    { name: "Queijo", quantity: 0, purchase_date: Date.today },
    { name: "Iogurte", quantity: 0, purchase_date: Date.today },
    { name: "Manteiga", quantity: 0, purchase_date: Date.today }
  ],
  "Padaria" => [
    { name: "Pão", quantity: 0, purchase_date: Date.today }
  ],
  "Carnes" => [
    { name: "Peito de Frango", quantity: 0, purchase_date: Date.today },
    { name: "Carne Moída", quantity: 0, purchase_date: Date.today },
    { name: "Costeletas de Porco", quantity: 0, purchase_date: Date.today },
    { name: "Bacon", quantity: 0, purchase_date: Date.today }
  ],
  "Frutos do Mar" => [
    { name: "Tilápia", quantity: 0, purchase_date: Date.today }
  ],
  "Despensa" => [
    { name: "Arroz", quantity: 0, purchase_date: Date.today },
    { name: "Macarrão", quantity: 0, purchase_date: Date.today },
    { name: "Azeite de Oliva", quantity: 0, purchase_date: Date.today },
    { name: "Farinha", quantity: 0, purchase_date: Date.today }
  ],
  "Bebidas" => [
    { name: "Café", quantity: 0, purchase_date: Date.today },
    { name: "Chá", quantity: 0, purchase_date: Date.today },
    { name: "Suco de Laranja", quantity: 0, purchase_date: Date.today },
    { name: "Água", quantity: 0, purchase_date: Date.today }
  ],
  "Produtos de Limpeza" => [
    { name: "Detergente", quantity: 0, purchase_date: Date.today },
    { name: "Sabão em Pó", quantity: 0, purchase_date: Date.today },
    { name: "Alvejante", quantity: 0, purchase_date: Date.today },
    { name: "Limpa Vidros", quantity: 0, purchase_date: Date.today }
  ],
  "Cuidados Pessoais" => [
    { name: "Shampoo", quantity: 0, purchase_date: Date.today },
    { name: "Pasta de Dente", quantity: 0, purchase_date: Date.today },
    { name: "Sabonete", quantity: 0, purchase_date: Date.today },
    { name: "Loção", quantity: 0, purchase_date: Date.today }
  ]
}

# Seeding the categories and items
categories.each do |category_name, items|
  category = Category.find_or_create_by!(name: category_name)
  items.each do |item_attributes|
    category.items.find_or_create_by!(name: item_attributes[:name])
  end
end

puts "Seeding complete!"
