class CategoriesController < ApplicationController
  before_filter :login_required, :except => :index
  cache_sweeper :category_sweeper, :only => [:create, :update, :destroy]

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

    respond_to do |format|
      format.html do
        @people = @category.people
      end
      format.json { render :json => @category.as_json(:only => [:id,:name], :include => {:people => {:methods => [:icon, :notifications], :only => [:id,:name,:icon,:notifications,:deactivated]}}) }
      format.xml  { render :xml => @category.to_xml(:only => [:id,:name], :include => {:people => {:methods => [:icon, :notifications], :only => [:id,:name,:icon,:notifications,:deactivated]}}) }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new
    @all_categories = Category.by_long_name

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    @all_categories = Category.by_long_name
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if can?(:create, @category) && @category.save
        flash[:success] = t('success_category_created')
        format.html { redirect_to(@category) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        @category = Category.new
        @all_categories = Category.by_long_name
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
      if can?(:update, @category) && @category.update_attributes(params[:category])
        flash[:notice] = t('notice_category_updated')
        format.html { redirect_to(@category) }
        format.xml  { head :ok }
      else
        @category = Category.find(params[:id])
        @all_categories = Category.by_long_name
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])

    respond_to do |format|
      if can?(:destroy, @category)
        @category.destroy
        format.html { redirect_to(categories_url) }
        format.xml  { head :ok }
      else
        @top_level_categories = Category.find(:all, :conditions => "parent_id is NULL").sort_by {|a| a.name}
        @categories = Category.find(:all).sort_by { |a| a.long_name }
        format.html { render :action => "index" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end
end
