class Admin::PeopleController < ApplicationController

  before_filter :login_required, :admin_required


  def index
    @people = Person.paginate(:all, :page => params[:page], :order => :name)
  end

  def update
    @person = Person.find(params[:id])
    case params[:task]
    when "deactivate"
      if current_person?(@person)
        flash[:error] = "You can't deactivate yourself"
      else
        @person.toggle(:deactivated)
        if @person.save
          flash[:success] = "#{@person.name} updated"
        else
          flash[:error] = "Error updating #{@person.name}"
        end
      end
    when "admin"
      if current_person?(@person)
        flash[:error] = "You can't unadmin yourself"
      else
        @person.toggle(:admin)
        if @person.save
          flash[:success] = "#{@person.name} updated"
        else
          flash[:error] = "Error updating #{@person.name}"
        end
      end
    end
    redirect_to admin_people_url
  end
end