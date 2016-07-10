module Fintech
  class Payment
    attr_accessor :amount_cents, :apply_to_future, :date

    def initialize(attrs = {})
      attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end
  end
end
