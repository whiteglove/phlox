module Phlox
  module Validators
    class StateValidator < ActiveModel::EachValidator
      # Uses offical USPS abbreviations - https://www.usps.com/send/official-abbreviations.htm
      VALID_STATES = %w(
        AL AK AS AZ AR CA CO CT DE DC FM FL GA GU HI ID IL IN IA KS KY LA ME MH MD MA MI MN MS MO MT NE NV NH NJ NM NY NC
        ND MP OH OK OR PW PA PR RI SC SD TN TX UT VT VI VA WA WV WI WY AE AA AP
      )

      def validate_each(record, attribute, value)
        record.errors[attribute] << 'must be a valid state (USPS)' unless VALID_STATES.include?(value)
      end
    end
  end
end
