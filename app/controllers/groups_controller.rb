class GroupsController < ApplicationController
  before_filter :login_required
  
  def index
    @groups = Group.find(:all)

    respond_to do |format|
      format.html
    end
  end

  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def new
    @group = Group.new

    respond_to do |format|
      format.html
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(group_path(@group)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(group_path(@group)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_path()) }
    end
  end
  
  def join
    @group = Group.find(params[:id])
    current_person.groups << @group
    respond_to do |format|
      format.html { redirect_to(group_path(@group)) }
    end
  end
  
  def desjoin
    @group = Group.find(params[:id])
    if current_person.groups.include?(@group)
      current_person.groups.delete(@group)
    end
    respond_to do |format|
      format.html { redirect_to(group_path(@group)) }
    end
  end
  
end
