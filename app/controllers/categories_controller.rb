class CategoriesController < ApplicationController

  before_filter :login_required, :except => :index
  before_filter :authorize_change, :only => [:update, :destroy] 

  # GET /categories
  # GET /categories.xml
  def index
    @top_level_categories = Category.find(:all, :conditions => "parent_id is NULL").sort_by {|a| a.name}
    @categories = Category.find(:all).sort_by { |a| a.long_name }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])
    @people = @category.active_people
    @reqs = @category.current_and_active_reqs
    @offers = @category.offers

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @category.to_json(:only => [:id,:name], :include => {:people => {:methods => [:icon, :notifications], :only => [:id,:name,:icon,:notifications,:deactivated]}}) }
      format.xml  { render :xml => @category.to_xml(:only => [:id,:name], :include => {:people => {:methods => [:icon, :notifications], :only => [:id,:name,:icon,:notifications,:deactivated]}}) }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        flash[:notice] = 'Category was successfully created.'
        format.html { redirect_to(@category) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to(@category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end

  private

  def authorize_change
    authorized = current_person.admin?
    flash[:error] = 'Authorization required to edit category'
    redirect_to home_url unless authorized
  end

end
