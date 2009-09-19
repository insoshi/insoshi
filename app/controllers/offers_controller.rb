class OffersController < ApplicationController
  def index
    @offers = Offer.current(params[:page])
  end

  def show
    @offer = Offer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @offer }
    end
  end

  def new
    @offer = Offer.new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
  end

  def create
    @offer = Offer.new(params[:offer])
    @offer.person_id = current_person.id

    respond_to do |format|
      if @offer.save
        flash[:notice] = 'Offer was successfully created.'
        format.html { redirect_to(@offer) }
        format.xml  { render :xml => @offer, :status => :created, :location => @offer }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { render :action => "new" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @offer = Offer.find(params[:id])
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
  end

  def update
    @offer = Offer.find(params[:id])

    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        flash[:notice] = 'Offer was successfully updated.'
        format.html { redirect_to(@offer) }
        format.xml  { head :ok }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @offer = Offer.find(params[:id])
    @offer.destroy

    respond_to do |format|
      format.html { redirect_to(offers_url) }
      format.xml  { head :ok }
    end
  end

end
