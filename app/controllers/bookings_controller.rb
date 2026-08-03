class BookingsController < ApplicationController
  def new
    @court = Court.find_by(id: params[:court_id]) || Court.new(name: "Court #{params[:court_id] || 'A'} (Mock)")
    @booking_date = params[:booking_date]
    @start_time = params[:start_time]
    @end_time = params[:end_time]
    
    # We are not implementing customer selection or database saving yet.
    # This prepares the data for the booking confirmation UI.
  end

  def create
    court = Court.find(params[:booking][:court_id])
    price = 500.00 # Default mock price for MVP
    
    # 1. Check if user has enough balance
    if @current_user.balance < price
      redirect_to court_path(court, booking_date: params[:booking][:booking_date]), alert: "เงินในบัญชีไม่เพียงพอกรุณาเติมเงิน"
      return
    end

    booking = Booking.new(
      court_id: court.id,
      customer_id: @current_user.id,
      booking_date: params[:booking][:booking_date],
      start_time: params[:booking][:start_time],
      end_time: params[:booking][:end_time],
      phonenumber: params[:booking][:phonenumber],
      price: price,
      status: 'booked'
    )

    # 2. Use Database Transaction to ensure both saving booking and deducting balance succeed together
    success = false
    Booking.transaction do
      if booking.save
        @current_user.update!(balance: @current_user.balance - price)
        success = true
      else
        raise ActiveRecord::Rollback
      end
    end

    if success
      redirect_to court_path(court, booking_date: booking.booking_date), notice: "Booking confirmed! ฿#{price} has been deducted from your balance."
    else
      redirect_to court_path(court, booking_date: params[:booking][:booking_date]), alert: "Failed to create booking: #{booking.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    booking = @current_user.bookings.find_by(id: params[:id])
    
    if booking.nil?
      redirect_to profile_path, alert: "Booking not found."
      return
    end
    
    if booking.status == 'cancelled'
      redirect_to profile_path, alert: "Booking is already cancelled."
      return
    end

    booking_datetime = Time.zone.local(
      booking.booking_date.year,
      booking.booking_date.month,
      booking.booking_date.day,
      booking.start_time.hour,
      booking.start_time.min,
      booking.start_time.sec
    )

    time_diff = booking_datetime - Time.current

    if time_diff < 0
      redirect_to profile_path, alert: "Cannot cancel a booking that has already started or passed."
      return
    end

    # 1. 100% refund if cancelled >= 60 minutes before start time
    # 2. 50% refund (250) if cancelled < 60 minutes before start time
    refund_amount = time_diff >= 60.minutes ? booking.price : 250.00
    penalty = booking.price - refund_amount

    success = false
    Booking.transaction do
      if booking.update(status: 'cancelled', cancelled_at: Time.current, penalty_amount: penalty)
        @current_user.update!(balance: @current_user.balance + refund_amount)
        success = true
      else
        raise ActiveRecord::Rollback
      end
    end

    if success
      msg = "Booking cancelled successfully. ฿#{refund_amount.to_f} has been refunded."
      msg += " (Late cancellation penalty: ฿#{penalty.to_f})" if penalty > 0
      redirect_to profile_path, notice: msg
    else
      redirect_to profile_path, alert: "Failed to cancel booking."
    end
  end
end
