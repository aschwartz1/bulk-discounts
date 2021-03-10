# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

bob = Merchant.create(name: "Bob Trufont", status: 1)
vinyl = bob.items.create(name: "Vinyl Record", description: "Old school music", unit_price: 12)
cd = bob.items.create(name: "Compact Disc", description: "Mid school music", unit_price: 10)
poster = bob.items.create(name: "Random Music Poster", description: "You never know what you're gonna get", unit_price: 10)
customer = Customer.create(first_name: "Brooks", last_name: "Conrad")
invoice = customer.invoices.create(status: 1)
invoice.invoice_items.create(item_id: vinyl.id, status: 2, quantity: 12, unit_price: 12)
invoice.invoice_items.create(item_id: cd.id, status: 2, quantity: 16, unit_price: 12)
invoice.invoice_items.create(item_id: poster.id, status: 2, quantity: 2, unit_price: 4)
invoice.transactions.create(credit_card_number: 111, credit_card_expiration_date: Date.new(2021, 10, 01), result: 1)
bob.bulk_discounts.create(name: "Eval Day Discount", threshold: 12, percent_discount: 20)

bernsteins = Merchant.create(name: "Bernsteins Diet Pills", status: 1)
pills = bernsteins.items.create(name: "Diet Pills", description: "BURN, THE FAT, STEINS", unit_price: 12)
customer = Customer.create(first_name: "Alex", last_name: "Bernstein")
invoice = customer.invoices.create(status: 1)
invoice.invoice_items.create(item_id: pills.id, status: 2, quantity: 16, unit_price: 12)
invoice.transactions.create(credit_card_number: 222, credit_card_expiration_date: Date.new(2021, 10, 01), result: 1)
bernsteins.bulk_discounts.create(name: "Always Discount", threshold: 10, percent_discount: 50)
bernsteins.bulk_discounts.create(name: "Never Discount", threshold: 14, percent_discount: 25)
