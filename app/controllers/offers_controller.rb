class OffersController < ApplicationController
  before_filter :login_required
  load_resource :group
  load_and_authorize_resource :offer, :through => :group, :shallow => true
  before_filter :correct_person_required, :only => [:edit, :update, :destroy]

  def index
    @selected_category = params[:category_id].nil? ? nil : Category.find(params[:category_id])
    @offers = Offer.search(@selected_neighborhood || @selected_category,
                           @group,
                           active=params[:scope].nil?, # if a scope is not passed, just return actives
                           params[:page],
                           AJAX_POSTS_PER_PAGE,
                           params[:search]
                           )

    respond_to do |format|
      format.xml { render :xml => @offers }
      format.js
    end
  end

  def show
    @offer = Offer.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @offer }
      format.js
    end
  end

  def new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @selected_neighborhoods = current_person.neighborhoods
    respond_to do |format|
      format.js
    end
  end

  def create
    @offer.group = @group
    ##TODO: move this to the model, a before_create method?
    @offer.available_count = @offer.total_available
    @offer.person = current_person

    respond_to do |format|
      if @offer.save
        flash[:notice] = t('success_offer_created')
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @offers = Offer.search(nil,@group,active=true,page=1,AJAX_POSTS_PER_PAGE,nil)
        format.js
        format.xml  { render :xml => @offer, :status => :created, :location => @offer }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.js {render :action => 'new'}
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @group = @offer.group
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    respond_to do |format|
      format.js
    end
  end

  def update
    @group = @offer.group

    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        flash[:notice] = t('notice_offer_updated')
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @offers = Offer.search(nil,@group,active=true,page=1,AJAX_POSTS_PER_PAGE,nil)
        #format.html { redirect_to(@offer) }
        format.js
        format.xml  { head :ok }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        #format.html { render :action => "edit" }
        format.js {render :action => 'edit'}
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    if can?(:destroy, @offer)
      flash[:notice] = t('success_offer_destroyed')
      @offer.destroy
    else
      flash[:error] = t('error_offer_cannot_be_deleted')
    end

    respond_to do |format|
      format.xml  { head :ok }
      format.js
    end
  end

private

  def correct_person_required
    redirect_to home_url unless ( current_person.admin? or Offer.find(params[:id]).person == current_person )
  end
end
