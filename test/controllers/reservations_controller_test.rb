require 'test_helper'

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  test 'request shows reservation' do
    get reservation_url(reservations(:example)), as: :json
    assert_response :success
  end

  test 'request creates guest and reservation with payload1' do
    assert_difference(['Guest.count', 'Reservation.count']) do
      params = payload1_format_params
      post reservations_url, params: params, as: :json
    end

    assert_response 201
  end

  test 'request updates guest and creates reservation with payload1' do
    guest = guests(:example)

    assert_difference({ 'Guest.count' => 0, 'Reservation.count' => 1 }) do
      params = payload1_format_params
      params[:guest][:id] = guest.id
      params[:guest][:email] = guest.email
      post reservations_url, params: params, as: :json
    end

    assert_response 201
  end

  test 'request fails to create guest and reservation with payload1' do
    guest = guests(:example)

    assert_no_difference(['Guest.count', 'Reservation.count']) do
      params = payload1_format_params
      params[:guest][:email] = guest.email # email validation should fail
      post reservations_url, params: params, as: :json
    end

    assert_response 422
  end

  def payload1_format_params
    {
      start_date: '2021-06-12',
      end_date: '2021-06-19',
      nights: 7,
      guests: 2,
      adults: 2,
      children: 0,
      infants: 0,
      status: 'accepted',
      guest: {
        id: 1,
        first_name: 'Emmanuel',
        last_name: 'Natividad',
        phone: '639123456789',
        email: 'emmanuel@natividad.me'
      },
      currency: 'PHP',
      payout_price: '3800.00',
      security_price: '500',
      total_price: '4500.00',
    }
  end
end
