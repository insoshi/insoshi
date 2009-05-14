class AddressesController < ApplicationController
  before_filter :login_required
  before_filter :correct_user_required
  before_filter :find_person

  def index
    @addresses = @person.addresses.find(:all)
    respond_to do |format|
      format.xml { render :xml => @addresses }
    end
  end

  def new
    @states = State.find(:all, :order => "name").collect {|s| [s.name, s.id]}
    @address = Address.new
  end

  def edit
    @states = State.find(:all, :order => "name").collect {|s| [s.name, s.id]}
    @address = @person.addresses.find(params[:id])
  end

  def create
    @address = Address.new(params[:address])
    begin
      if @person.addresses << @address
        redirect_to person_url(@person)
      else
        @states = State.find(:all, :order => "name").collect {|s| [s.name, s.id]}
        render :action => :new
      end
    rescue
      @states = State.find(:all, :order => "name").collect {|s| [s.name, s.id]}
      flash[:error] = "Geocoding failed."
      render :action => :new
    end
  end

  def update
    @address = @person.addresses.find(params[:id])
    begin
      if @address.update_attributes(params[:address])
        redirect_to person_url(@person)
      else
        @states = State.find(:all, :order => "name").collect {|s| [s.name, s.id]}
        render :action => :edit
      end
    rescue
      @states = State.find(:all, :order => "name").collect {|s| [s.name, s.id]}
      flash[:error] = "Geocoding failed."
      render :action => :edit
    end
  end

private
  def correct_user_required
    redirect_to home_url unless Person.find(params[:person_id]) == current_person
  end

  def find_person
    @person_id = params[:person_id]
    redirect_to home_url and return unless @person_id
    @person = Person.find(@person_id)
  end
end
