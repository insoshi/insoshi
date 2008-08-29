# -*- coding: utf-8 -*-
class EventsController < ApplicationController

  before_filter :login_required
  before_filter :load_date, :only => :index
  
  def index
    @month_events = Event.monthly_events(@date).person_events(current_person)
    unless filter_by_day?
      @events = @month_events
    else
      @events = Event.daily_events(@date).person_events(current_person)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  def show
    @event = Event.find(params[:id])
    @date = @event.start_time.to_date
    @month_events = Event.monthly_events(@date).person_events(current_person)
    @attendees = @event.attendees.paginate(:page => params[:page], :per_page => RASTER_PER_PAGE)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def edit
    @event = Event.find(params[:id])
    check_owner
  end

  def create
    @event = Event.new(params[:event].merge(:person => current_person))

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @event = Event.find(params[:id])
    check_owner

    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @event = Event.find(params[:id])
    check_owner

    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  def attend
    @event = Event.find(params[:id])
    if @event.attend(current_person)
      flash[:notice] = "You are attending this event."
      redirect_to @event
    else
      flash[:error] = "You can only attend once."
      redirect_to @event
    end
  end

  def unattend
    @event = Event.find(params[:id])
    if @event.unattend(current_person)
      flash[:notice] = "You are not attending this event."
      redirect_to @event
    else
      flash[:error] = "You are not attending this event."
      redirect_to @event
    end

  end

  private
  def check_owner
    redirect_to home_url unless current_person?(@event.person)
  end

  def load_date
    now = Time.now
    year = (params[:year]||now.year).to_i
    month = (params[:month]||now.month).to_i
    day = (params[:day]||now.mday).to_i
    @date = Date.new(year,month,day)
  rescue ArgumentError
    @date = Time.now.to_date
  end

  def filter_by_day?
    !params[:day].nil?
  end

end
