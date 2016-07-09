module Fintech
  class Loan
    attr_accessor :amount_cents, :rate, :term, :funding_date, :installment_dates

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
      @installments = []
      installment_dates.each_with_index do |date, index|
        start_date = index == 0 ? funding_date : installment_dates[index - 1]
        beginning_balance = index == 0 ? amount_cents : @installments[index - 1][:ending_balance]
        beginning_interest = index == 0 ? 0 : @installments[index - 1][:ending_interest]
        accrued_interest = (date - start_date) * rate.daily * beginning_balance
        paid_interest = [beginning_interest + accrued_interest, payment_cents].min
        payment = date == installment_dates.last ? beginning_balance + beginning_interest + accrued_interest : payment_cents
        principal = payment - paid_interest
        @installments << {
          date: date,
          beginning_balance: beginning_balance,
          beginning_interest: beginning_interest,
          accrued_interest: accrued_interest,
          paid_interest: paid_interest,
          ending_interest: beginning_interest + accrued_interest - paid_interest,
          principal: principal,
          payment_cents: payment.truncate,
          ending_balance: beginning_balance - principal,
        }
      end
      @installments
    end

    def inspect
      "<Fintech::Loan amount_cents: #{amount_cents}, rate: #{rate.annual}, term: #{term}, funding_date: #{funding_date}>"
    end
  end
end
