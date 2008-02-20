class PeopleController < ApplicationController
  
  
  
  # render new.rhtml
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

end
