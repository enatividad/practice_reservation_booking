module Reservations
  class Create
    # @param param [ActionController::Parameters] unparsed params from external
    #   apis
    def initialize(params)
      @params = params
    end

    # After either creating a new guest or updating an existing one, creates a
    # reservation that is associated to that guest.
    def run
      reservation = nil
      errors = []

      parsed_params = parse_payload1_format_params
      guest_params = parsed_params[:guest]
      reservation_params = parsed_params[:reservation]

      ActiveRecord::Base.transaction do
        guest = Guest.find_or_initialize_by(id: reservation_params[:guest_id])
        guest.attributes = guest_params
        unless guest.save
          errors.concat guest.errors.to_a.map { |e| "Guest: #{e}" }
          raise ActiveRecord::Rollback
        end

        reservation = Reservation.new(reservation_params)
        reservation.guest = guest
        unless reservation.save
          errors.concat reservation.errors.to_a
          raise ActiveRecord::Rollback
        end
      end

      result = {}
      result[:reservation] = reservation
      result[:body] =
        if reservation
          { data: reservation.as_json(include: :guest) }
        else
          { errors: errors }
        end
      result
    end

    private

    def parse_payload1_format_params
      guest = @params[:guest]
      guest = {
        id: guest[:id],
        email: guest[:email],
        first_name: guest[:first_name],
        last_name: guest[:last_name],
        phone_list: guest[:phone],
      }

      reservation = {
        guest_id: guest[:id],
        start_date: Date.parse(@params[:start_date]),
        end_date: Date.parse(@params[:end_date]),
        nights: @params[:nights],
        guests: @params[:guests],
        adults: @params[:adults],
        children: @params[:children],
        infants: @params[:infants],
        status: @params[:status],
        currency: @params[:currency],
        payout_price: BigDecimal(@params[:payout_price]),
        security_price: BigDecimal(@params[:security_price]),
        total_price: BigDecimal(@params[:total_price]),
      }

      { guest: guest, reservation: reservation }
    end
  end
end
