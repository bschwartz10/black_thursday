class Merchant
  attr_reader :id,
              :name,
              :created_at,
              :updated_at,
              :parent

  def initialize(attributes, parent = nil)
    @id = attributes[:id].to_i
    @created_at = Time.parse(attributes[:created_at])
    @updated_at = Time.parse(attributes[:updated_at])
    @name = attributes[:name]
    @parent = parent
  end

  def items
    parent.parent.items.find_all_by_merchant_id(id)
  end

  def invoices
    parent.parent.invoices.find_all_by_merchant_id(id)
  end

  def customers
    customer_ids = invoices.map { |invoice| invoice.customer_id }
    customer_ids.map { |id| parent.parent.customers.find_by_id(id) }.uniq
  end

  def revenue
    merchant_invoices = parent.parent.invoices.find_all_by_merchant_id(id)
    paid_invoices = merchant_invoices.select do |invoice|
      invoice.is_paid_in_full?
    end
    paid_invoices.reduce(0) { |sum, invoice| sum + invoice.total }
  end

  def has_pending_invoices?
    invoices.any? { |invoice| !invoice.is_paid_in_full? }
  end

  def has_one_item?
    items.count == 1
  end

end
