module Phlox
  module Validators
    class CountryValidator < ActiveModel::EachValidator
      # please use ISO 3166-1 alpha-3 country names
      VALID_COUNTRIES = %w(USA MEX CAN)

      def validate_each(record, attribute, value)
        record.errors[attribute] << 'must be a valid country (ISO 3166-1 alpha-3)' unless VALID_COUNTRIES.include?(value)
      end
    end
  end
end
