class PeopleController < ApplicationController
  
  before_filter :login_required, :only => [ :edit, :update ]
  before_filter :correct_user_required, :only => [ :edit, :update ]
  
  def index
    @people = Person.active(params[:page])

    respond_to do |format|
      format.html
    end
  end
  
  def show
    @person = Person.find(params[:id])
    @contacts = @person.some_contacts
    if @person.deactivated?
      flash[:error] = "That person has been deactivated"
      redirect_to home_url and return
    end
    if current_person?(@person)
      link = edit_person_path(@person)
      flash.now[:notice] = %(You are viewing your own profile.
                             <a href="#{link}">Click here to edit it</a>)
    end
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
        if global_prefs.email_verifications?
          flash[:notice] = %(Thanks for signing up! A verification email has 
                             been sent to #{@person.email}.)
          @person.toggle!(:deactivated)
          @verification = EmailVerification.create(:person => @person)
          @person.email_verifications << @verification
          format.html { redirect_to(home_url) }
        else
          flash[:notice] = "Thanks for signing up!"
          format.html { redirect_back_or_default(home_url) }
        end
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def verify
    verification = EmailVerification.find_by_code(params[:id])
    if verification.nil?
      flash[:error] = "Invalid email verification code"
      redirect_to home_url
    else
      verification.person.toggle!(:deactivated)
      flash[:success] = "Email verified.  Your profile is active!"
      redirect_to verification.person
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
      case params[:type]
      when 'info_edit'
        if @person.update_attributes(params[:person])
          flash[:success] = 'Profile updated!'
          format.html { redirect_to(@person) }
        else
          format.html { render :action => "edit" }
        end
      when 'password_edit'
        if @person.change_password?(params[:person])
          flash[:success] = 'Password changed.'
          format.html { redirect_to(@person) }
        else
          format.html { render :action => "edit" }
        end
      end
    end
  end
  
  private
  
  def correct_user_required
    redirect_to home_url unless Person.find(params[:id]) == current_person
  end
end
