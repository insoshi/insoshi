class OffersController < ApplicationController

  respond_to :html, :xml, :json, :js

  before_filter :login_required
  load_resource :group
  load_and_authorize_resource :offer, :through => :group, :shallow => true
  before_filter :correct_person_required, :only => [:edit, :update, :destroy]

  def index
    @selected_category = params[:category_id].nil? ? nil : Category.find(params[:category_id])
    @offers = Offer.custom_search(@selected_neighborhood || @selected_category,
                                  @group,
                                  active=params[:scope].nil?, # if a scope is not passed, just return actives
                                  params[:page],
                                  AJAX_POSTS_PER_PAGE,
                                  params[:search]
                                  ).order("offers.updated_at desc")
    respond_with @offers
  end

  def show
    respond_with @offer
  end

  def new
    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name
    @selected_neighborhoods = current_person.neighborhoods
    respond_to do |format|
      format.js
      format.html { redirect_to group_path(@group, :anchor => 'offers/new') }
    end
  end

  def create
    @offer.group = @group
    @offer.person = current_person
    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name

    respond_to do |format|
      if @offer.save
        flash[:notice] = t('success_offer_created') if @offer.save
        @offers = Offer.custom_search(nil,@group,active=true,page=1,AJAX_POSTS_PER_PAGE,nil).order("updated_at desc")
        #respond_with @offer
        #format.html { redirect_to(@offer) }
        format.js
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.js { render :action => "new" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @group = @offer.group
    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name
    respond_to do |format|
      format.js
    end
  end

  def update
    @group = @offer.group
    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name

    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        flash[:notice] = t('notice_offer_updated')
        @offers = Offer.custom_search(nil,@group,active=true,page=1,AJAX_POSTS_PER_PAGE,nil).order("updated_at desc")
        #format.html { redirect_to(@offer) }
        format.js
        format.xml  { head :ok }
      else
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

  def new_photo
    @photo = Photo.new
    respond_to do |format|
      format.html
    end
  end

  def save_photo
    if params[:photo].nil?
      # This is mainly to prevent exceptions on iPhones.
      flash[:error] = t('error_browser_upload_fail')
      redirect_to(offer_path(@offer)) and return
    end
    if params[:commit] == "Cancel"
      flash[:notice] = t('notice_upload_canceled')
      redirect_to(offer_path(@offer)) and return
    end
    
    offer_data = { :photoable => @offer,
                    :primary => @offer.photos.empty? }
    @photo = Photo.new(params[:photo].merge(offer_data))
    
    respond_to do |format|
      if @photo.save
        flash[:success] = t('success_photo_uploaded')
        redirect_to offer_path(@offer) and return
      else
        format.html { render :action => "new_photo" }
      end
    end
  end

  # private

  def correct_person_required
    redirect_to home_url unless ( current_person.admin? or Offer.find(params[:id]).person == current_person )
  end
end
