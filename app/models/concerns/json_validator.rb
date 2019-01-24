# Usage in your model:
#   validates :json_attribute, presence: true, json: true
#
# To have a detailed error use something like:
#   validates :json_attribute, presence: true, json: {message: :some_i18n_key}
# In your yaml use:
#   some_i18n_key: "detailed exception message: %{exception_message}"
class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(message: :invalid)
    super(options)
  end

  def validate_each(record, attribute, value)
    value_before_cast = record.send(attribute.to_s + '_before_type_cast')

    return if value.blank? && value_before_cast.blank?

    check_value = if value_before_cast.is_a?(Hash) || value_before_cast.is_a?(Array)
                    value_before_cast.to_json
                  elsif value_before_cast.is_a?(String)
                    value_before_cast.strip
                  else
                    value_before_cast
                  end

    ::JSON.parse(check_value)
  rescue StandardError => exception
    record.errors.add(attribute, options[:message], exception_message: exception.message)
  end
end
