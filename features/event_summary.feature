@vcr @wip
Feature: Create a JSON description of all upcoming events

  In order to display upcoming events on the main website
  As a developer
  I want to be able to access a JSON file including the details from some client-side Javascript
  
  Background:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And that event has a url 'http://www.eventbrite.co.uk/event/5441375300'
    And that event starts at 2013-03-17 19:00
    And that event ends at 2013-03-17 22:00
    And that event is being held at 'The office'
    And that event has 99 tickets called "Free Ticket" which cost GBP 0.00
    And that ticket type is on sale from 2013-03-01 09:00
    And that ticket type is on sale until 2013-03-10 09:00
    And that event has 100 tickets called "Cheap Ticket" which cost GBP 0.38
    And that ticket type is on sale from 2013-03-01 09:00
    And that ticket type is on sale until 2013-03-16 09:00
    And another event in Eventbrite called "How to Find an Eventbrite Event ID" with id 5449726278
    And that event has a url 'http://foobarrubbishevent.eventbrite.co.uk/'
    And that event starts at 2013-03-24 19:00
    And that event ends at 2013-03-24 22:00
    And that event has 9 tickets called "Free" which cost GBP 0.00
    And that ticket type is on sale from 2013-03-01 09:00
    And that ticket type is on sale until 2013-03-24 18:00
    And another event in Eventbrite called "Open Data, Law and Licensing" with id 5519765768  
    And that event has a url 'http://www.eventbrite.co.uk/event/5519765768'
    And that event starts at 2013-04-16 09:30
    And that event ends at 2013-04-16 12:30
    And that event has 100 tickets called "Full Registration" which cost GBP 225.00
    And that ticket type is on sale from 2013-03-01 09:00
    And that ticket type is on sale until 2013-04-16 08:30
    And that event has 100 tickets called "Early Bird" which cost GBP 190.00
    And that ticket type is on sale from 2013-03-01 09:00
    And that ticket type is on sale until 2013-04-16 08:30
    And that event has 100 tickets called "Members, Civil Servants and Charities" which cost GBP 180.00
    And that ticket type is on sale from 2013-03-01 09:00
    And that ticket type is on sale until 2013-04-16 08:30
  
  Scenario: Queue event summary generator
    Then the event summary generator should be queued
		When we poll eventbrite for all events
    
  Scenario: Generate JSON
    Then the summary uploader should be queued with the following JSON:
    """
    {
      "http://www.eventbrite.co.uk/event/5441375300": {
        "@type": "http://schema.org/Event",
        "startDate": "2013-03-17T19:00:00+00:00",
        "endDate": "2013-03-17T22:00:00+00:00",
        "location": {
          "@type": "http://schema.org/Place",
          "name": "The office"
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Free Ticket",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validFrom": "2013-03-01T09:00:00+00:00",
            "validThrough": "2013-03-10T09:00:00+00:00",
            "inventoryLevel": 99
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Cheap Ticket",
            "price": 0.38,
            "priceCurrency": "GBP",
            "validFrom": "2013-03-01T09:00:00+00:00",
            "validThrough": "2013-03-16T09:00:00+00:00",
            "inventoryLevel": 100
          }
        ]
      },
      "http://foobarrubbishevent.eventbrite.co.uk/": {
        "@type": "http://schema.org/Event",
        "startDate": "2013-03-24T19:00:00+00:00",
        "endDate": "2013-03-24T22:00:00+00:00",
        "location": {
          "@type": "http://schema.org/Place",
          "name": null
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Free",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validFrom": "2013-03-01T09:00:00+00:00",
            "validThrough": "2013-03-24T18:00:00+00:00",
            "inventoryLevel": 9
          }
        ]
      },
      "http://www.eventbrite.co.uk/event/5519765768": {
        "@type": "http://schema.org/Event",
        "startDate": "2013-04-16T09:30:00+00:00",
        "endDate": "2013-04-16T12:30:00+00:00",
        "location": {
          "@type": "http://schema.org/Place",
          "name": null
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Full Registration",
            "price": 225.0,
            "priceCurrency": "GBP",
            "validFrom": "2013-03-01T09:00:00+00:00",
            "validThrough": "2013-04-16T08:30:00+00:00",
            "inventoryLevel": 100
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Early Bird",
            "price": 190.0,
            "priceCurrency": "GBP",
            "validFrom": "2013-03-01T09:00:00+00:00",
            "validThrough": "2013-04-16T08:30:00+00:00",
            "inventoryLevel": 100
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Members, Civil Servants and Charities",
            "price": 180.0,
            "priceCurrency": "GBP",
            "validFrom": "2013-03-01T09:00:00+00:00",
            "validThrough": "2013-04-16T08:30:00+00:00",
            "inventoryLevel": 100
          }
        ]
      }
    }
    """
		When the event summary generator is run

  Scenario: Upload JSON to web server
    Given a JSON document like this:
    """
    {"foo":"bar"}
    """
    When the summary uploader runs
    Then the JSON document should be available at the target URL