require 'test_helper'

class GuestTest < ActiveSupport::TestCase
  setup do
    @guest = Guest.new(
      email: 'emmanuel@natividad.me',
      first_name: 'Emmanuel',
      last_name: 'Natividad',
      phone_list: "639123456789\n639123456789",
    )
  end

  test 'record is valid' do
    assert guests(:example).valid?
  end

  test 'email is insensitively unique' do
    @guest.email = guests(:example).email
    assert_not @guest.valid?

    @guest.email = @guest.email.swapcase
    assert_not @guest.valid?
  end
end
