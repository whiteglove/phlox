module Phlox
  module Validators
    class HonorificValidator < ActiveModel::EachValidator
      VALID_TITLES = %w(Mr. Mrs. Ms. Dr.)

      def validate_each(record, attribute, value)
        record.errors[attribute] << 'must be a valid honorific' unless VALID_TITLES.include?(value)
      end
    end
  end
end
