class CustomersController < ApplicationController
  def show
    # @current_user is already set by ApplicationController#set_current_user
    @bookings = @current_user.bookings.includes(:court).order(booking_date: :desc, start_time: :desc)
  end
end
