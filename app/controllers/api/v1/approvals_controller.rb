module Api
  module V1
    class ApprovalsController < BaseController
      include UserAuthenticatable

      before_action :ensure_profile_complete, only: [:create]

      # GET /api/v1/approvals
      def index
        approvals = current_user.approvals.includes(:venue, :event)

        render json: {
          approvals: approvals.map { |a| approval_json(a) }
        }, status: :ok
      end

      # GET /api/v1/approvals/:id
      def show
        approval = current_user.approvals.find(params[:id])

        render json: {
          approval: approval_json(approval, include_qr: true)
        }, status: :ok
      end

      # POST /api/v1/approvals
      def create
        venue = Venue.find(approval_params[:venue_id])

        approval = current_user.approvals.build(
          venue: venue,
          approval_type: approval_params[:approval_type],
          status: :pending
        )

        if approval_params[:event_id].present?
          event = venue.events.find(approval_params[:event_id])
          approval.event = event
        end

        if approval.save
          render json: {
            message: "Approval request submitted",
            approval: approval_json(approval)
          }, status: :created
        else
          render json: { error: approval.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/approvals/:id/qr_code
      def qr_code
        approval = current_user.approvals.find(params[:id])

        unless approval.approved?
          return render json: { error: "Approval not yet granted" }, status: :forbidden
        end

        format = params[:format] || "svg"

        case format.downcase
        when "svg"
          render json: { qr_code_svg: approval.qr_code_svg }, status: :ok
        when "png"
          png = approval.qr_code_png
          send_data png.to_s, type: "image/png", disposition: "inline"
        else
          render json: { qr_code_data: approval.qr_code_data }, status: :ok
        end
      end

      private

      def approval_params
        params.require(:approval).permit(:venue_id, :event_id, :approval_type)
      end

      def ensure_profile_complete
        unless current_user.profile_complete?
          render json: {
            error: "Please complete your profile (upload photo and ID card) before requesting approval"
          }, status: :forbidden
        end
      end

      def approval_json(approval, include_qr: false)
        json = {
          id: approval.id,
          venue: {
            id: approval.venue.id,
            name: approval.venue.name
          },
          event: approval.event ? {
            id: approval.event.id,
            name: approval.event.name,
            date_time: approval.event.date_time
          } : nil,
          approval_type: approval.approval_type,
          status: approval.status,
          active: approval.active?,
          qr_used: approval.qr_used,
          expires_at: approval.expires_at,
          created_at: approval.created_at
        }

        if include_qr && approval.approved?
          json[:qr_code_data] = approval.qr_code_data
        end

        json
      end
    end
  end
end
