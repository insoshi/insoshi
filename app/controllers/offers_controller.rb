class OffersController < ApplicationController
  before_filter :login_required
  before_filter :correct_person_required, :only => [:edit, :update, :destroy]

  def index
    @offers = Offer.current(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @offers }
    end
  end

  def show
    @offer = Offer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @offer }
      format.js
    end
  end

  def new
    @offer = Offer.new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @groups = current_person.groups.delete_if {|g| !g.adhoc_currency?}
  end

  def create
    @offer = Offer.new(params[:offer])
    @offer.available_count = @offer.total_available
    @offer.person_id = current_person.id

    respond_to do |format|
      if @offer.save
        flash[:success] = t('success_offer_created')
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
        flash[:notice] = t('notice_offer_updated')
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
    if @offer.can_destroy?
      @offer.destroy
    else
      flash[:error] = t('error_offer_cannot_be_deleted')
    end

    respond_to do |format|
      format.html { redirect_to(offers_url) }
      format.xml  { head :ok }
    end
  end

private

  def correct_person_required
    redirect_to home_url unless ( current_person.admin? or Offer.find(params[:id]).person == current_person )
  end
end
