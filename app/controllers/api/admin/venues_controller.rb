module Api

  module Admin
    class VenuesController < BaseController
      before_action :set_venue, only: [:show, :update, :destroy]

      # GET /api/v1/admin/venues
      def index
        venues = current_user.venues

        render json: {
          venues: venues.map { |v| venue_json(v) }
        }, status: :ok
      end

      # GET /api/v1/admin/venues/:id
      def show
        render json: {
          venue: venue_json(@venue, include_stats: true)
        }, status: :ok
      end

      # POST /api/v1/admin/venues
      def create
        venue = current_user.venues.build(venue_params)

        if venue.save
          render json: {
            message: "Venue created successfully",
            venue: venue_json(venue)
          }, status: :created
        else
          render json: { error: venue.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/admin/venues/:id
      def update
        if @venue.update(venue_params)
          render json: {
            venue: venue_json(@venue)
          }, status: :ok
        else
          render json: { error: @venue.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/admin/venues/:id
      def destroy
        @venue.destroy
        render json: { message: "Venue deleted successfully" }, status: :ok
      end

      private

      def set_venue
        @venue = current_user.venues.find(params[:id])
      end

      def venue_params
        params.require(:venue).permit(:name, :description, :address)
      end

      def venue_json(venue, include_stats: false)
        json = {
          id: venue.id,
          name: venue.name,
          description: venue.description,
          address: venue.address,
          created_at: venue.created_at,
          updated_at: venue.updated_at
        }

        if include_stats
          json[:stats] = {
            total_events: venue.events.count,
            upcoming_events: venue.events.upcoming.count,
            pending_approvals: venue.approvals.pending.count,
            approved_users: venue.approvals.approved.count
          }
        end

        json
      end
    end
  end

end
