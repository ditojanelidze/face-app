module Api

  class VenuesController < BaseController
    include UserAuthenticatable

    # GET /api/v1/venues
    def index
      venues = Venue.all

      render json: {
        venues: venues.map { |v| venue_json(v) }
      }, status: :ok
    end

    # GET /api/v1/venues/:id
    def show
      venue = Venue.find(params[:id])

      render json: {
        venue: venue_json(venue, include_events: true)
      }, status: :ok
    end

    # GET /api/v1/venues/:id/events
    def events
      venue = Venue.find(params[:id])
      events = venue.events.upcoming

      render json: {
        events: events.map { |e| event_json(e) }
      }, status: :ok
    end

    private

    def venue_json(venue, include_events: false)
      json = {
        id: venue.id,
        name: venue.name,
        description: venue.description,
        address: venue.address,
        created_at: venue.created_at
      }

      if include_events
        json[:upcoming_events] = venue.events.upcoming.map { |e| event_json(e) }
      end

      json
    end

    def event_json(event)
      {
        id: event.id,
        name: event.name,
        description: event.description,
        date_time: event.date_time,
        allow_global_approval: event.allow_global_approval,
        upcoming: event.upcoming?
      }
    end
  end
end
