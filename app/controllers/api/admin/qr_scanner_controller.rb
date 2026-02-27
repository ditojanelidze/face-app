module Api
  module Admin
    class QrScannerController < BaseController
      before_action :set_venue

      # POST /api/v1/admin/venues/:venue_id/scan
      def scan
        qr_code_data = scan_params[:qr_code_data]
        event_id = scan_params[:event_id]

        approval = Approval.find_by(qr_code_data: qr_code_data)

        unless approval
          return render json: {
            valid: false,
            error: "Invalid QR code"
          }, status: :ok
        end

        # Check venue ownership
        unless approval.venue_id == @venue.id
          return render json: {
            valid: false,
            error: "This QR code is not for this venue"
          }, status: :ok
        end

        # Check if approved
        unless approval.approved?
          return render json: {
            valid: false,
            error: "Approval is not active (status: #{approval.status})"
          }, status: :ok
        end

        # Check expiration
        if approval.expired?
          return render json: {
            valid: false,
            error: "Approval has expired"
          }, status: :ok
        end

        # Check if already used (if single-use is required)
        if approval.qr_used? && !allow_multiple_scans?
          return render json: {
            valid: false,
            error: "QR code has already been used"
          }, status: :ok
        end

        # For event-specific approval, check if event matches
        if approval.event_specific?
          if event_id.present?
            unless approval.event_id == event_id.to_i
              return render json: {
                valid: false,
                error: "This approval is not valid for this event"
              }, status: :ok
            end
          end
        elsif approval.global?
          # For global approval, check if the event allows global approvals
          if event_id.present?
            event = @venue.events.find_by(id: event_id)
            if event && !event.allow_global_approval
              return render json: {
                valid: false,
                error: "This event does not accept global approvals"
              }, status: :ok
            end
          end
        end

        # Mark as used if single-use
        approval.mark_as_used! unless allow_multiple_scans?

        render json: {
          valid: true,
          message: "Entry allowed",
          user: {
            id: approval.user.id,
            full_name: approval.user.full_name,
            profile_photo_url: approval.user.profile_photo.attached? ? url_for(approval.user.profile_photo) : nil
          },
          approval: {
            id: approval.id,
            type: approval.approval_type,
            event: approval.event ? {
              id: approval.event.id,
              name: approval.event.name
            } : nil
          }
        }, status: :ok
      end

      # POST /api/v1/admin/venues/:venue_id/validate
      # Validates without marking as used (for preview)
      def validate
        qr_code_data = scan_params[:qr_code_data]

        approval = Approval.find_by(qr_code_data: qr_code_data)

        unless approval
          return render json: {
            valid: false,
            error: "Invalid QR code"
          }, status: :ok
        end

        render json: {
          valid: approval.active? && approval.venue_id == @venue.id,
          approval: approval.active? && approval.venue_id == @venue.id ? {
            id: approval.id,
            type: approval.approval_type,
            status: approval.status,
            qr_used: approval.qr_used,
            user: {
              id: approval.user.id,
              full_name: approval.user.full_name
            }
          } : nil
        }, status: :ok
      end

      private

      def set_venue
        @venue = current_user.venues.find(params[:venue_id])
      end

      def scan_params
        params.permit(:qr_code_data, :event_id)
      end

      def allow_multiple_scans?
        # This could be a venue setting in the future
        params[:allow_multiple_scans] == "true"
      end
    end
  end

end
