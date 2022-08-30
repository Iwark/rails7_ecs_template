class PhoneNumberValidator < ActiveModel::EachValidator
  
  PHONE_REGEX = /\A
    (((0(
      \d{1}[-(]?\d{4}|        # 01-1234
      \d{2}[-(]?\d{3}|        # 012-123
      \d{3}[-(]?\d{2}|        # 0123-12
      \d{4}[-(]?\d{1}|        # 01234-1
      [5789]0[-(]?\d{4}       # mobile 080-1234
    )[-)]?)|
      \d{1,4}-?               # without area code 1234-
    )\d{4}|
    0120[-(]?\d{3}[-)]?\d{3}) # toll-free 0120-123-456
  \z/x
  
  
  def validate_each(record, attr, value)
    return if value.blank? || value =~ PHONE_REGEX
    
    record.errors.add(attr, options[:message] || :invalid_format)
  end
end
