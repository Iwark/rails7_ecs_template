# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhoneNumberValidator, type: :model do
  describe '#validate_each' do
    valid_values = [
      '03-1234-5678',
      '03(1234)5678',
      '080-1234-5678',
      '0120-123-456',
      '0312345678',
      '12345678'
    ]

    invalid_values = [
      'invalid phone number',
      '030-1234-5678',
      '0124-123-456'
    ]

    valid_values.each do |val|
      context "when valid phone number: '#{val}' is given" do
        let(:mock) { build_validator_mock.new(attribute: val) }

        before do
          mock.valid?
        end

        it 'is valid' do
          expect(mock).to be_valid
        end
      end
    end

    invalid_values.each do |val|
      context "when invalid value: '#{val}' is given" do
        let(:mock) { build_validator_mock.new(attribute: val) }

        before do
          mock.valid?
        end

        it 'is invalid' do
          expect(mock).to be_invalid
        end

        it 'raises invalid_phone_number_format error' do
          expect(mock.errors).to be_added(:attribute, :invalid_phone_number_format)
        end
      end
    end
  end
end
