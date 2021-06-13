class ReservationsController < ApplicationController
  # GET /reservations/1
  def show
    @reservation = Reservation.find(params[:id])
    render json: { data: @reservation.as_json(include: :guest) }
  end

  # POST /reservations
  def create
    result = Reservations::Create.new(reservation_params).run
    body = result[:body]
    reservation = result[:reservation]

    if body.include?(:data)
      render json: body, status: :created, location: reservation
    else
      render json: body, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def reservation_params
    params.permit!
  end
end
