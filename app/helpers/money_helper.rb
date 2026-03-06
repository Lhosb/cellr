module MoneyHelper
  def format_cents(amount_cents, currency_symbol: "$", precision: 2)
    amount = amount_cents.to_i / 100.0
    number_to_currency(amount, unit: currency_symbol, precision: precision)
  end
end
