# Usage in your model:
#   validates :json_attribute, presence: true, json: true
#
# To have a detailed error use something like:
#   validates :json_attribute, presence: true, json: {message: :some_i18n_key}
# In your yaml use:
#   some_i18n_key: "detailed exception message: %{exception_message}"
class JsonValidator < ActiveModel::EachValidator

  def initialize(options)
    options.reverse_merge!(:message => :invalid)
    super(options)
  end

  def validate_each(record, attribute, value)
    begin
      value = value.strip if value.is_a?(String)
      if value.blank?
        return true
      end
      ActiveSupport::JSON.decode(value.to_s)
    rescue => exception
      record.errors.add(attribute, options[:message], exception_message: exception.message)
    end
  end

end