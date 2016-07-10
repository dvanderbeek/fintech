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
      payment_cents / 100.0
    end

    def installment_dates
      @installment_dates ||= (1..term).map do |n|
        funding_date.next_month(n)
      end
    end

    def installments
      @installments ||= installment_dates.each_with_object([seed_installment]) do |date, array|
        array.push Installment.new(
          beginning_balance: array.last.ending_balance,
          beginning_interest: array.last.ending_interest,
          start_date: array.last.end_date,
          end_date: date,
          rate: rate,
          standard_payment_cents: payment_cents,
          final: date == installment_dates.last,
        )
      end.drop(1)
    end

    def payments
      @payments ||= []
    end

    def pay_installments
      installments.each do |installment, hash|
        next if installment.paid
        add_payment(
          date: installment.end_date,
          amount_cents: installment.payment_cents
        )
        installment.paid = true
      end
    end

    def add_payment(date:, amount_cents:, apply_to_future: false)
      payments.push Payment.new(
        date: date,
        amount_cents: amount_cents,
        apply_to_future: apply_to_future
      )
    end

    def daily_stats
      # TODO: extend to cover remaining balance (if any)
      (funding_date..installment_dates.last).each_with_object([seed_stat]) do |date, array|
        array.push Stat.new(
          date: date,
          previous: array.last,
          rate: rate,
          installment: installments.find { |i| i.end_date == date },
          payments: payments.select { |p| p.date == date },
          fees_assessed: 0,
        )
      end.drop(1)
    end

    def inspect
      "<Fintech::Loan amount_cents: #{amount_cents}, rate: #{rate.annual}, term: #{term}, funding_date: #{funding_date}>"
    end

    private

    def seed_stat
      OpenStruct.new(
        ending_balance: amount_cents,
        total_principal_due: 0,
        total_principal_paid: 0,
        total_interest_paid: 0,
        total_interest_income: 0,
        total_interest_due: 0,
        ending_interest: 0,
        ending_fees: 0,
        ending_apply_to_future_credits: 0,
      )
    end

    def seed_installment
      OpenStruct.new(
        end_date: funding_date,
        ending_balance: amount_cents,
        ending_interest: 0,
      )
    end
  end
end
