module Phlox
  module Validators
    class SexValidator < ActiveModel::EachValidator
      VALID_SEX = ['Male', 'Female']

      def validate_each(record, attribute, value)
        record.errors[attribute] << 'must be a valid sex (Male or Female)' unless VALID_SEX.include?(value)
      end

    end
  end
end
