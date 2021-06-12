require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  test 'record is valid' do
    assert reservations(:example).valid?
  end
end
