require './test/test_helper'
require './lib/merchant'
require './lib/sales_engine'

class MerchantTest < Minitest::Test
  include SalesEngineTestSetup

  def setup
    super
    @m = Merchant.new({
      id:"12334105",
      name:"Shopin1901" ,
      created_at:"2010-12-10" ,
      updated_at:"2011-12-04"
      })
  end

  def test_it_exists
    assert_instance_of Merchant, @m
  end

  def test_merchant_id
    assert_equal 12334105, @m.id
  end

  def test_merchant_name
    assert_equal "Shopin1901", @m.name
  end

  def test_find_items_by_merchant_id
    merchant = @se.merchants.find_by_id(12334783)

    assert_instance_of Array, merchant.items
    assert_equal 4, merchant.items.count
    assert_equal "Freedom", merchant.items.first.name
  end

  def test_invoices_attached_to_merchant
    merchant = @se.merchants.find_by_id(12334159)

    assert_instance_of Array, merchant.invoices
    assert_equal 13, merchant.invoices.count
    assert_equal 44, merchant.invoices.first.customer_id
  end

  def test_customers_attached_to_merchant
    merchant = @se.merchants.find_by_id(12335938)

    assert_instance_of Array, merchant.customers
    assert_instance_of Customer, merchant.customers.first
  end

  def test_merchant_revenue
    merchant = @se.merchants.find_by_id(12335938)
    assert_equal 0.1263009e6, merchant.revenue
  end

  def test_has_pending_invoices?
    merchant = @se.merchants.find_by_id(12335938)
    assert_equal true, merchant.has_pending_invoices?
  end

  def test_has_one_item?
    merchant_1 = @se.merchants.find_by_id(12335938)
    merchant_2 = @se.merchants.find_by_id(12334112)
    assert_equal false, merchant_1.has_one_item?
    assert_equal true, merchant_2.has_one_item?

  end
end
