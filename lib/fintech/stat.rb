module Fintech
  class Stat
    attr_accessor :date, :previous, :rate, :installment, :fees_assessed

    def initialize(attrs = {})
      attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

    def payment_cents
      installment ? installment.payment_cents : 0
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

    def total_interest_paid
      @total_interest_paid ||= previous.total_interest_paid + interest_paid
    end

    # fees
    def beginning_fees
      @beginning_fees ||= previous.ending_fees
    end

    def fees_paid
      @fees_paid ||= [[beginning_fees, payment_cents].min, 0].max
    end

    def ending_fees
      @ending_fees ||= beginning_fees + fees_assessed - fees_paid
    end

    def inspect
      "<Fintech::Stat ending_balance: #{ending_balance}>"
    end
  end
end
