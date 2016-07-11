module Fintech
  class Benchmark
    def self.run
      "Time take n: #{(time * 1000).round(2)} milliseconds; Ending Balance: #{@stats.last.ending_principal.round(2)} cents."
    end

    def self.time
      ::Benchmark.realtime {
        l = Loan.new(amount_cents: 10000_00, rate: 0.1, term: 60, funding_date: Date.new(2015, 12, 1))
        l.pay_installments
        l.add_payment(amount_cents: 100_00, date: Date.new(2015, 12, 20), apply_to_future: true)
        @stats = l.daily_stats
      }
    end
  end
end
