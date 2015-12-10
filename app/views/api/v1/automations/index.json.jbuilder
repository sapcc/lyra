json.array!(@automations) do |automation|
  json.extract! automation, :id, :name, :type
  json.url automation_url(automation, format: :json)
end
