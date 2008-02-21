class PeopleController < ApplicationController
  
  def index
    @people = Person.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def new
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
  end

  def update
    respond_to do |format|
      if current_person.update_attributes(params[:person])
        flash[:success] = 'Profile updated!'
        format.html { redirect_to(current_person) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end
