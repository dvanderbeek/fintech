module Fintech
  class Loan
    attr_accessor :amount_cents, :rate, :term, :funding_date

    def initialize(attrs = {})
      self.amount_cents = attrs.fetch(:amount_cents, 0)
      self.rate = attrs.fetch(:rate, 0)
      self.funding_date = attrs.fetch(:funding_date, Date.today)
      self.term = attrs.fetch(:term, 12)
    end

    def rate=(rate)
      @rate = Fintech::Rate::Simple.new(rate)
    end

    def payment_cents
      (rate.monthly * amount_cents / (1 - (1 + rate.monthly) ** -term)).round
    end

    def payment_dollars
      payment_cents.to_f / 100
    end

    def installment_dates
      @installment_dates = (1..term).map do |n|
        funding_date.next_month(n)
      end
    end

    def installments
      @installments = installment_dates.each_with_object([seed_installment]) do |date, array|
        array.push Installment.new(
          beginning_balance: array.last.ending_balance,
          beginning_interest: array.last.ending_interest,
          start_date: array.last.end_date,
          end_date: date,
          rate: rate,
          standard_payment_cents: payment_cents,
          final: date == installment_dates.last,
        )
      end[1..-1]
    end

    def inspect
      "<Fintech::Loan amount_cents: #{amount_cents}, rate: #{rate.annual}, term: #{term}, funding_date: #{funding_date}>"
    end

    private

    def seed_installment
      OpenStruct.new(ending_balance: amount_cents, ending_interest: 0, end_date: funding_date)
    end
  end
end
