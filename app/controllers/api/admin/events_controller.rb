module Api
  module Admin
    class EventsController < BaseController
      before_action :set_venue
      before_action :set_event, only: [:show, :update, :destroy]

      # GET /api/v1/admin/venues/:venue_id/events
      def index
        events = @venue.events.order(date_time: :desc)

        render json: {
          events: events.map { |e| event_json(e) }
        }, status: :ok
      end

      # GET /api/v1/admin/venues/:venue_id/events/upcoming
      def upcoming
        events = @venue.events.upcoming

        render json: {
          events: events.map { |e| event_json(e) }
        }, status: :ok
      end

      # GET /api/v1/admin/venues/:venue_id/events/:id
      def show
        render json: {
          event: event_json(@event, include_stats: true)
        }, status: :ok
      end

      # POST /api/v1/admin/venues/:venue_id/events
      def create
        event = @venue.events.build(event_params)

        if event.save
          render json: {
            message: "Event created successfully",
            event: event_json(event)
          }, status: :created
        else
          render json: { error: event.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/admin/venues/:venue_id/events/:id
      def update
        if @event.update(event_params)
          render json: {
            event: event_json(@event)
          }, status: :ok
        else
          render json: { error: @event.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/admin/venues/:venue_id/events/:id
      def destroy
        @event.destroy
        render json: { message: "Event deleted successfully" }, status: :ok
      end

      private

      def set_venue
        @venue = current_user.venues.find(params[:venue_id])
      end

      def set_event
        @event = @venue.events.find(params[:id])
      end

      def event_params
        params.require(:event).permit(:name, :description, :date_time, :allow_global_approval)
      end

      def event_json(event, include_stats: false)
        json = {
          id: event.id,
          name: event.name,
          description: event.description,
          date_time: event.date_time,
          allow_global_approval: event.allow_global_approval,
          upcoming: event.upcoming?,
          created_at: event.created_at,
          updated_at: event.updated_at
        }

        if include_stats
          json[:stats] = {
            pending_approvals: event.approvals.pending.count,
            approved_users: event.approvals.approved.count,
            rejected_users: event.approvals.rejected.count
          }
        end

        json
      end
    end
  end

end
