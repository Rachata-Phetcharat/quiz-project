class CourtsController < ApplicationController
  def show
    @court = Court.find_by(id: params[:id]) || Court.first
    unless @court
      @court = Court.create!(name: "Center Court")
    end
    @selected_date = params[:booking_date].present? ? Date.parse(params[:booking_date]) : Date.today
    
    booked_times = []
    if @court.persisted?
      booked_times = Booking.where(court_id: @court.id, booking_date: @selected_date, status: 'booked').pluck(:start_time)
      booked_times = booked_times.compact.map { |t| t.strftime('%H:%M') }
    end

    is_maintenance_day = (@court.status == 'maintenance' && @court.maintenance_date == @selected_date)

    @slots = (6..22).map do |hour|
      time_str = format('%02d:00', hour)
      status = if is_maintenance_day
                 'maintenance'
               elsif booked_times.include?(time_str)
                 'booked'
               else
                 'available'
               end
      
      {
        start_time: time_str,
        end_time: format('%02d:00', hour + 1),
        status: status
      }
    end
  end

  def edit
    @court = Court.find(params[:id])
  end

  def update
    @court = Court.find(params[:id])
    if @court.update(court_params)
      # Force cancel bookings if maintenance date is set
      if @court.status == 'maintenance' && @court.maintenance_date.present?
        bookings_to_cancel = Booking.where(court_id: @court.id, booking_date: @court.maintenance_date, status: 'booked')
        
        Booking.transaction do
          bookings_to_cancel.each do |booking|
            booking.update!(status: 'cancelled', cancelled_at: Time.current, penalty_amount: 0)
            if booking.customer
              booking.customer.update!(balance: booking.customer.balance + booking.price)
            end
          end
        end
      elsif @court.status == 'open'
        @court.update_column(:maintenance_date, nil)
      end

      redirect_to court_path(@court), notice: "Court updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def court_params
    params.require(:court).permit(:name, :status, :maintenance_date)
  end
end
