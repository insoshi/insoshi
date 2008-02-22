class PeopleController < ApplicationController
  
  before_filter :correct_user_required, :only => [ :edit, :update ]
  
  def index
    @people = Person.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @person = Person.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @person = Person.new

    respond_to do |format|
      format.html
    end
  end

  def create
    cookies.delete :auth_token
    @person = Person.new(params[:person])
    respond_to do |format|
      if @person.save
        self.current_person = @person
        flash[:notice] = "Thanks for signing up!"
        format.html { redirect_back_or_default(home_url) }
      else
        format.html { render :action => 'new' }
      end
    end
  end


  def edit
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def update
    @person = current_person
    respond_to do |format|
      if @person.update_attributes(params[:person])
        flash[:success] = 'Profile updated!'
        format.html { redirect_to(@person) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  private
  
  def correct_user_required
    redirect_to home_url unless Person.find(params[:id]) == current_person
  end
end
