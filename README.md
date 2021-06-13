# README

This app is currently deployed in Heroku. These are the relevant urls:
- [base url](https://enatividad-reservation-booking.herokuapp.com/) -
  `https://enatividad-reservation-booking.herokuapp.com/`
- [create reservation](https://enatividad-reservation-booking.herokuapp.com/reservations.json) -
  `https://enatividad-reservation-booking.herokuapp.com/reservations.json`
- [show reservation](https://enatividad-reservation-booking.herokuapp.com/reservations/1.json) -
  `https://enatividad-reservation-booking.herokuapp.com/reservations/1.json`

I have added 2 records after deploying this app:
- [`/reservations/1.json`](https://enatividad-reservation-booking.herokuapp.com/reservations/1.json) -
  example resulting record when `Payload 1` format is used as request payload
- [`/reservations/2.json`](https://enatividad-reservation-booking.herokuapp.com/reservations/2.json) -
  example resulting record when `Payload 2` format is used as request payload

## Implementation Notes

- This app was developed using `rbenv`-managed `ruby 2.6.7`
- This app assumes that if `Guest` record of `Payload 1` has an id of `1` and
  if `Guest` record of `Payload 2` has an id of `2`, __THEN `Payload 1 Guest`
  and `Payload 2 Guest` are the same records__
  - This assumption can imply that `Payload 1` and `Payload 2` retrieve their
    data from the same data source
  - This assumption has led me to implement `Guest` so that if record with
    id `1` is present, the `create reservation` endpoint updates the existing
    `Guest` record instead of creating a new one. For clarification,
    `Reservation` records are always created.
- This app makes as little assumptions as possible, leading to an implementation
  with minimal model validations
  - `Guest#email` can either be `nil` or an arbitrary string, as this
    implementation intends
- Please refer to the code samples below for `Payload 1` and `Payload 2`

__Payload 1__
```json
{
  "start_date": "2021-03-12",
  "end_date": "2021-03-16",
  "nights": 4,
  "guests": 4,
  "adults": 2,
  "children": 2,
  "infants": 0,
  "status": "accepted",
  "guest": {
    "id": 1,
    "first_name": "Wayne",
    "last_name": "Woodbridge",
    "phone": "639123456789",
    "email": "wayne_woodbridge@bnb.com"
  },
  "currency": "AUD",
  "payout_price": "3800.00",
  "security_price": "500",
  "total_price": "4500.00"
}
```

__Payload 2__
```json
{
  "reservation": {
    "start_date": "2021-03-12",
    "end_date": "2021-03-16",
    "expected_payout_amount": "3800.00",
    "guest_details": {
      "localized_description": "4 guests",
      "number_of_adults": 2,
      "number_of_children": 2,
      "number_of_infants": 0
    },
    "guest_email": "wayne_woodbridge@bnb.com",
    "guest_first_name": "Wayne",
    "guest_id": 1,
    "guest_last_name": "Woodbridge",
    "guest_phone_numbers": [
      "639123456789",
      "639123456789"
    ],
    "listing_security_price_accurate": "500.00",
    "host_currency": "AUD",
    "nights": 4,
    "number_of_guests": 4,
    "status_type": "accepted",
    "total_paid_amount_accurate": "4500.00"
  }
}
```

## Dependencies

- Ruby version: `2.6.7`
- System dependencies:
  - ruby
  - postgresql

## Development Environment Setup

- run `bin/setup` from inside the project directory
  - if the database cannot be created, either configure `config/database.yml` to
    use your postgresql credentials OR configure your postgresql installation to
    work with the current `config/database.yml`
- run `bin/rails test` to execute the test suite

## Production Environment Setup

- install [heroku-cli](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)
- run `heroku login` from the terminal
  - make a Heroku account if you do not have one
- configure your ssh keys from inside your Heroku account
- run `heroku create` from inside the project directory
- run `git push heroku master`
- run `heroku run rails db:migrate`
- run `heroku ps:scale web=1`
- run `heroku open`. if the browser doesn't open, manually click the generated
  app url.
- use the app's base url by making api requests in:
  - GET `/reservations/:id.json`
  - POST `/reservations.json`
