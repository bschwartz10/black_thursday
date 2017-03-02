require_relative 'sales_engine'
require_relative 'data_analysis'

class SalesAnalyst
  include DataAnalysis
  attr_reader :sales_engine,
              :merchants,
              :items,
              :invoices,
              :invoice_items,
              :transactions,
              :customers

  def initialize(sales_engine)
    @sales_engine = sales_engine
    @merchants ||= sales_engine.merchants
    @items ||= sales_engine.items
    @invoices ||= sales_engine.invoices
    @invoice_items ||= sales_engine.invoice_items
    @transactions ||= sales_engine.transactions
    @customers ||= sales_engine.customers
  end

  def average_items_per_merchant
    average(items.all.count, merchants.all.count)
  end

  def average_items_per_merchant_standard_deviation
    items_per_merchant = merchants.all.map { |merchant| merchant.items.count }
    std_dev_from_array(items_per_merchant)
  end

  def merchants_with_high_item_count
    min_item_count = average_items_per_merchant +
        average_items_per_merchant_standard_deviation
    merchants.all.find_all { |merchant| merchant.items.count > min_item_count }
  end

  def average_item_price_for_merchant(merchant_id)
    item_prices = merchants.find_by_id(merchant_id).items.map {
      |item| item.unit_price }
    (item_prices.inject(:+) / item_prices.count).round(2)
  end

  def average_average_price_per_merchant
    price = merchants.all.inject(0) do |sum, merchant|
      sum + average_item_price_for_merchant(merchant.id)
    end
    (price / merchants.all.count).round(2)
  end

  def average_price_per_item_standard_deviation
    prices = items.all.collect { |item| item.unit_price_to_dollars }
    std_dev_from_array(prices)
  end

  def golden_items
    std_dev = average_price_per_item_standard_deviation
    sum_price = items.all.inject(0) do |sum, object|
      sum + object.unit_price_to_dollars
    end
    mean = sum_price / sales_engine.items.all.count
    min_price = (std_dev * 2 ) + mean
    sales_engine.items.all.find_all do |item|
      item.unit_price > min_price
    end
  end

  def average_invoices_per_merchant
    average(invoices.all.count, merchants.all.count)
  end

  def average_invoices_per_merchant_standard_deviation
    invoices_per_merchant = merchants.all.map do |merchant|
      merchant.invoices.count
    end
    std_dev_from_array(invoices_per_merchant)
  end

  def top_merchants_by_invoice_count
    std_dev = average_invoices_per_merchant_standard_deviation
    mean = average_invoices_per_merchant
    count = (std_dev * 2 ) + mean
    merchants.all.find_all do |merchant|
      merchant.invoices.count > count
    end
  end

  def bottom_merchants_by_invoice_count
    std_dev = average_invoices_per_merchant_standard_deviation
    mean = average_invoices_per_merchant
    count = mean - (std_dev * 2 )
    merchants.all.find_all do |merchant|
      merchant.invoices.count < count
    end
  end

  def top_days_by_invoice_count
    days_of_week = invoices.all.map { |x| x.created_at.strftime("%A") }

    invoices_per_day = Hash.new(0)
    days_of_week.map { |day| invoices_per_day[day] += 1 }

    average = average(invoices_per_day.values, invoices_per_day.values.count)
    std_dev = std_dev_from_array(invoices_per_day.values)

    invoice_min = average + std_dev
    invoices_per_day.select { |key, value| value > invoice_min }.keys
  end

  def invoice_status(status)
    invoice_status_count = invoices.find_all_by_status(status).count.to_f
    percentage = (invoice_status_count / invoices.all.count.to_f) * 100
    percentage.round(2)
  end

  def total_revenue_by_date(date)
    invoice_date = invoices.find_all_by_date(date)
    invoice_date.reduce(0) do |sum, invoice|
      sum + invoice.total
    end
  end

  def revenue_by_merchant(id)
    merchant = merchants.find_by_id(id)
    merchant.revenue
  end

  def top_revenue_earners(number = 20)
    results = merchants.all.max_by(number) { |merchant| merchant.revenue }
  end

  def merchants_with_pending_invoices
    merchants.all.find_all do |merchant|
      merchant.has_pending_invoices?
    end
  end

  def merchants_ranked_by_revenue
    sorted = merchants.all.sort_by do |merchant|
      merchant.revenue
    end
    sorted.reverse
  end

  def merchants_with_only_one_item
    merchants.all.find_all do |merchant|
      merchant.has_one_item?
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.select do |merchant|
      merchant.created_at.strftime("%B") == month
    end
  end

  def most_sold_item_for_merchant(id)
    merchant = merchants.find_by_id(id)
    successful_invoices = merchant.invoices.select do |invoice|
      invoice.is_paid_in_full?
    end

    invoice_merchant_items = successful_invoices.map do |invoice|
      invoice_items.find_all_by_invoice_id(invoice.id)
    end

    top_seller_invoice = invoice_merchant_items.flatten.max_by do |invoice_item|
      invoice_item.quantity
    end

    top_invoices = invoice_merchant_items.flatten.select do |invoice_item|
      top_seller_invoice.quantity == invoice_item.quantity
    end

    top_invoices.map do |invoice_item|
      items.find_by_id(invoice_item.item_id)
    end
  end

  def best_item_for_merchant(merchant_id)
    merchant = merchants.find_by_id(merchant_id)
    successful_invoices = merchant.invoices.select do |invoice|
      invoice.is_paid_in_full?
    end

    invoice_merchant_items = successful_invoices.map do |invoice|
      invoice_items.find_all_by_invoice_id(invoice.id)
    end

    top_seller_invoice = invoice_merchant_items.flatten.max_by do |invoice_item|
      invoice_item.unit_price * invoice_item.quantity
    end

    items.find_by_id(top_seller_invoice.item_id)
  end

end
