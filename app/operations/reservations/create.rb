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

      parsed_params = parse_params
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

    def parse_params
      if @params.include?(:reservation)
        parse_payload2_format_params
      else
        parse_payload1_format_params
      end
    end

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

    def parse_payload2_format_params
      reservation_params = @params[:reservation]

      guest = {
        id: reservation_params[:guest_id],
        email: reservation_params[:guest_email],
        first_name: reservation_params[:guest_first_name],
        last_name: reservation_params[:guest_last_name],
        phone_list: reservation_params[:guest_phone_numbers].join("\n"),
      }

      guest_details_params = reservation_params[:guest_details]
      reservation = {
        guest_id: guest[:id],
        start_date: Date.parse(reservation_params[:start_date]),
        end_date: Date.parse(reservation_params[:end_date]),
        nights: reservation_params[:nights],
        guests: reservation_params[:number_of_guests],
        adults: guest_details_params[:number_of_adults],
        children: guest_details_params[:number_of_children],
        infants: guest_details_params[:number_of_infants],
        localized_description: guest_details_params[:localized_description],
        status: reservation_params[:status_type],
        currency: reservation_params[:host_currency],
        payout_price: BigDecimal(reservation_params[:expected_payout_amount]),
        security_price: BigDecimal(reservation_params[:listing_security_price_accurate]),
        total_price: BigDecimal(reservation_params[:total_paid_amount_accurate]),
      }

      { guest: guest, reservation: reservation }
    end
  end
end
