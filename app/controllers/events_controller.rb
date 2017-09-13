class EventsController < ApplicationController
  def index
		@future_events = Event.where('event_date >= ?', Time.zone.now.to_date + 7)
		@this_weeks_events = Event.where('event_date >= ?', Time.zone.now.to_date).where('event_date < ?', Time.zone.now.to_date + 7)
  end

	def past
		@past_events = Event.where('event_date < ?', Time.zone.now.to_date)
	end

  def new
		@event = Event.new
		@cancel_path = events_path
  end

	def edit
		@event = Event.find(params[:id])
		@cancel_path = event_path(@event)
		@event.event_time = @event.event_date.to_time.in_time_zone('Sydney')
	end

  def create
		@event = Event.new(event_params)

		if @event.save
			flash[:success] = 'Event created successfully';
			redirect_to @event
		else
			render 'new'
		end
  end

  def update
		@event = Event.find(params[:id])

		if @event.update_attributes(event_params)
			flash[:success] = 'Event updated successfully'
			redirect_to @event
		else
			render 'edit'
		end
  end

  def show
		@event = Event.find(params[:id])
  end

	private

		def event_params
			new_date = Time.parse(params[:event][:event_time] + " " + params[:event][:event_date])
			params[:event][:event_date] = new_date
			params.require(:event).permit(:title, :event_date, :location, :repeat, :event_type)
		end
end
