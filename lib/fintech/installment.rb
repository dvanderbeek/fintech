module Fintech
  class Installment
    attr_accessor :start_date, :end_date, :beginning_balance,
                  :beginning_interest, :rate, :standard_payment_cents,
                  :final, :paid

    def initialize(attrs = {})
      attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

    def accrued_interest
      (end_date - start_date) * rate.daily * beginning_balance
    end

    def paid_interest
      [beginning_interest + accrued_interest, payment_cents].min
    end

    def ending_interest
      beginning_interest + accrued_interest - paid_interest
    end

    def payment_cents
      if final
        (beginning_balance + beginning_interest + accrued_interest).truncate
      else
        standard_payment_cents
      end
    end

    def principal
      payment_cents - paid_interest
    end

    def ending_balance
      beginning_balance - principal
    end

    def inspect
      "<Fintech::Installment beginning_balance: #{beginning_balance}, payment: #{payment_cents}, principal: #{principal}, interest: #{paid_interest}, ending_balance: #{ending_balance}>"
    end
  end
end
