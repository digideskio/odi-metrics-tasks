require 'eventbrite-client'
require 'attendee_invoicer'

class EventMonitor
  def initialize options = {}
    @event_id = options[:event_id]
  end

  def check_invoices
    e = EventbriteClient.new ({ :app_key => ENV["EVENTBRITE_API_KEY"], :user_key => ENV["EVENTBRITE_USER_KEY"]})
    if response = e.event_list_attendees(id: @event_id, page: 0)
      response.parsed_response['attendees'].each do |attendee|
        a = attendee['attendee']
        if a['order_type'] == "Send an Invoice - Payment Not Received"
          Resque.enqueue(AttendeeInvoicer, a['email'], a['amount_paid'].to_f)
        end
      end
    end
  end
end