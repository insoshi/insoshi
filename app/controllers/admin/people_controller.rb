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
        @person.toggle_activation!
        flash[:success] = "#{@person.name} updated."
      end
      redirect_to admin_people_url
    end
  end

  private

    def admin_required
      redirect_to home_url unless current_person.admin?
    end
end