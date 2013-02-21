Given /^the number (#{INTEGER}) has been queued for publishing in the (.*?) stat$/ do |value, stat|
  @number = value.to_s
  @stat = statistic_id(stat)
end

Then /^the number (#{INTEGER}) should be published to the leftronic (.*?) stat$/ do |value, stat|
  WebMock.should have_requested(:post, "https://beta.leftronic.com/customSend/").with(
    :body => %{\{"accessKey":"#{ENV['LEFTRONIC_API_KEY']}","streamName":"#{statistic_id(stat)}","point":"#{value}"\}}
  ).once
end

When /^the leftronic publisher runs$/ do
  if @html
    LeftronicPublisher.perform('html', @stat, @html)
  elsif @number
    LeftronicPublisher.perform('number', @stat, @number)
  end
end

Given /^the HTML '(.*?)' has been queued for publishing in the (.*?) stat$/ do |html, stat|
  @html = html
  @stat = statistic_id(stat)
end

Then /^the HTML '(.*?)' should be published to the leftronic (.*?) stat$/ do |html, stat|
  WebMock.should have_requested(:post, "https://beta.leftronic.com/customSend/").with(
    :body => %{\{"accessKey":"#{ENV['LEFTRONIC_API_KEY']}","streamName":"#{statistic_id(stat)}","point":\{"html":"#{html}"\}\}}
  ).once
end

Given /^that it's (#{DATETIME})$/ do |datetime|
  Timecop.freeze(datetime)
end

When /^the dashboard time publisher runs$/ do
  DashboardTime.perform
end