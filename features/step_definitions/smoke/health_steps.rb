When(/^I go to the health check$/) do
  visit "/healthcheck"
end

Then(/^I should see "(.*?)"$/) do |arg1|
  expect(page).to have_content(arg1)
end