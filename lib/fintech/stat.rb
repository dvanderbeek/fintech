module Fintech
  class Stat
    attr_accessor :date, :previous, :rate, :installment, :payments, :fees_assessed

    def initialize(attrs = {})
      attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

    def scheduled_payment_cents
      @scheduled_payment_cents ||= if payments.any?
        [payments.map(&:amount_cents).reduce(:+), remaining_balance].min.truncate
      else
        0
      end
    end

    def payment_cents
      @payment_cents ||= scheduled_payment_cents - apply_to_future_credits_applied
    end

    def payment_dollars
      @payment_dollars ||= payment_cents / 100.0
    end

    def remaining_balance
      @remaining_balance ||= beginning_balance + beginning_interest +
                             beginning_fees + fees_assessed
    end

    # apply to future
    def beginning_apply_to_future_credits
      @beginning_apply_to_future_credits ||= previous.ending_apply_to_future_credits
    end

    def apply_to_future_credits_earned
      @apply_to_future_credits_earned ||= payments.inject(0) do |memo, payment|
        memo += (payment.apply_to_future ? payment.amount_cents : 0)
      end
    end

    def apply_to_future_credits_applied
      @apply_to_future_credits_applied ||= if installment
        [scheduled_payment_cents, beginning_apply_to_future_credits].min
      else
        0
      end
    end

    def ending_apply_to_future_credits
      @ending_apply_to_future_credits ||= beginning_apply_to_future_credits +
                                          apply_to_future_credits_earned -
                                          apply_to_future_credits_applied
    end

    # principal
    def beginning_balance
      @beginning_balance ||= previous.ending_balance
    end

    def ending_balance
      @ending_balance ||= beginning_balance - principal
    end

    def principal
      @principal ||= payment_cents - fees_paid - interest_paid
    end

    def principal_due
      @principal_due ||= installment ? installment.principal : 0
    end

    def total_principal_due
      @total_principal_due ||= previous.total_principal_due + principal_due
    end

    def total_principal_paid
      @total_principal_paid ||= previous.total_principal_paid + principal
    end

    def principal_receivable
      @principal_receivable ||= total_principal_due - total_principal_paid
    end

    # interest
    def beginning_interest
      @beginning_interest ||= previous.ending_interest
    end

    def interest_paid
      @interest_paid ||= [payment_cents - fees_paid, beginning_interest].min
    end

    def interest_accrued
      @interest_accrued ||= [ending_balance, 0].max * rate.daily
    end

    def ending_interest
      @ending_interest ||= beginning_interest + interest_accrued - interest_paid
    end

    def total_interest_income
      @total_interest_income ||= previous.total_interest_income + interest_accrued
    end

    def total_interest_due
      @total_interest_due ||= if installment
        previous.total_interest_income
      else
        previous.total_interest_due
      end
    end

    def total_interest_paid
      @total_interest_paid ||= previous.total_interest_paid + interest_paid
    end

    def interest_receivable
      @interest_receivable ||= total_interest_due - total_interest_paid
    end

    # fees
    def beginning_fees
      @beginning_fees ||= previous.ending_fees
    end

    def fees_paid
      @fees_paid ||= [[beginning_fees + fees_assessed, payment_cents].min, 0].max
    end

    def ending_fees
      @ending_fees ||= beginning_fees + fees_assessed - fees_paid
    end

    def accounts_receivable
      @accounts_receivable ||= principal_receivable + interest_receivable
    end

    def inspect
      "<Fintech::Stat date: #{date}, ending_balance: #{ending_balance.truncate}>"
    end
  end
end
