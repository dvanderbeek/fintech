require 'spec_helper'

RSpec.describe Fintech::Loan do
  describe '.initialize' do
    it 'accepts a hash of attributes' do
      loan = described_class.new(amount_cents: 1000_00)
      expect(loan.amount_cents).to eq 1000_00
    end

    it 'disregards unknown attrs' do
      loan = described_class.new(amount_cents: 1000_00, test: 123)
      expect { loan.test }.to raise_error NoMethodError
    end

    it 'has a default amount_cents of 0' do
      loan = described_class.new
      expect(loan.amount_cents).to eq 0
    end

    it 'has a default funding_date of today' do
      loan = described_class.new
      expect(loan.funding_date).to eq Date.today
    end
  end

  describe '#rate=' do
    it 'sets the rate to a Fintech::Rate::Simple' do
      loan = described_class.new(rate: 0.1)
      expect(loan.rate).to be_a Fintech::Rate::Simple
    end
  end
end
