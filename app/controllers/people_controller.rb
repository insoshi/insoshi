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
  end
  
  def new
    @person = Person.new
  end

  def create
    cookies.delete :auth_token
    @person = Person.new(params[:person])
    @person.save
    if @person.errors.empty?
      self.current_person = @person
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end


  def edit
    @person = Person.find(params[:id])
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
