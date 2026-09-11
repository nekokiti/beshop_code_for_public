# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
# For Creating default company to Devise 

Company.create(email: '', password: '', company_name: '')
Product.create(name: 'test_product_1', url: 'http://www.test.co.jp/product/1', image_path: 'http://www.test.co.jp/product/img/1', description: 'test', price: 500, quantity: 10)
#Product.create(name: 'test_product_2', url: 'http://www.test.co.jp/product/2', image_path: 'http://www.test.co.jp/product/img/2', description: 'test', price: 800, quantity: 20)

#Company
#Company.create(email: '', password: '')

#SampleLineUserForDev
#LineUser.create(line_id: 'samplelineid')

#SampleTagForDev
#Tag.create(tag_name: 'かわいい')
#Tag.create(tag_name: 'かっこいい')

#SampleTagProductsForDev
#Tagging.create(tag_id: 1, product_id: 1)
#Tagging.create(tag_id: 2, product_id: 2)
#Tagging.create(tag_id: 2, product_id: 3)
