FactoryBot.define do
   factory :bulk_discount do
     name { "#{Faker::Hipster.words(number: 1)} Discount" }
     threshold { rand(2..10) }
     percent_discount { [5, 10, 12, 15, 20].sample }
     merchant
   end
 end
