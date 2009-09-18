class Admin::GroupsController < ApplicationController

  before_filter :login_required, :admin_required
  
  def index
    @groups = Group.paginate(:all, :page => params[:page], :order => :name)
    
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      flash[:notice] = 'Group was successfully deleted.'
      format.html { redirect_to(admin_groups_path) }
    end
  end
end
