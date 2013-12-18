module Phlox
  module Validators
    class EthnicityValidator < ActiveModel::EachValidator
      VALID_ETHNICITY = ['hisp_or_latin', 'not_hisp_or_latin']

      def validate_each(record, attribute, value)
        record.errors[attribute] << 'must be a valid ethnicity' unless VALID_ETHNICITY.include?(value)
      end
    end
  end
end
