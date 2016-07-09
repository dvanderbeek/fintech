require 'spec_helper'

RSpec.describe Fintech::Rate::Simple do
  describe '#daily' do
    it 'returns the rate / 365' do
      rate = described_class.new(0.1)
      expect(rate.daily).to eq 0.1 / 365
    end
  end

  describe '#monthly' do
    it 'returns the rate / 12' do
      rate = described_class.new(0.1)
      expect(rate.monthly).to eq 0.1 / 12
    end
  end
end
