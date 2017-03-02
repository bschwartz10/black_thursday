class Transaction

  attr_reader :id,
              :invoice_id,
              :credit_card_number,
              :credit_card_expiration_date,
              :result,
              :created_at,
              :updated_at,
              :parent

  def initialize(trans_data, parent = nil)
    @id = trans_data[:id].to_i
    @invoice_id = trans_data[:invoice_id].to_i
    @credit_card_number = trans_data[:credit_card_number].to_i
    @credit_card_expiration_date = trans_data[:credit_card_expiration_date].to_s
    @result = trans_data[:result]
    @created_at = Time.parse(trans_data[:created_at])
    @updated_at = Time.parse(trans_data[:updated_at])
    @parent = parent
  end

  def invoice
    parent.parent.invoices.find_by_id(invoice_id)
  end


end
