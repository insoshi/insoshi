class Admin::PeopleController < ApplicationController

  before_filter :login_required, :admin_required


  def index
    @people = Person.paginate(:all, :page => params[:page], :order => :name)
  end

  def update
    @person = Person.find(params[:id])
    if @person.last_admin?
      flash[:error] = "Action failed&mdash;you're the last admin."
    else
      @person.toggle!(params[:task])
      flash[:success] = "#{h @person.name} updated"
    end
    respond_to do |format|
      format.html { redirect_to admin_people_url }
    end
  end
end