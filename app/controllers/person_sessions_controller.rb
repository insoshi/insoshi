# This controller handles the login/logout function of the site.
class PersonSessionsController < ApplicationController

  skip_before_filter :require_activation, :only => [:new, :destroy]

  def new
    @person_session = PersonSession.new
    @body = "login single-col"
  end


  def create
    @person_session = PersonSession.new(params[:person_session])
    @person_session.save do |result|
      if result
        unless params[:person_session].nil?
          logger.info "OSC LOGIN SUCCESS: #{params[:person_session][:email]} from #{request.remote_ip}"
        end
        redirect_back_or_default root_url
      end
    end
    if !performed?
      #flash[:error] = t('error_authentication_failed')
      unless params[:person_session].nil?
        logger.info "OSC LOGIN FAILURE: #{params[:person_session][:email]} from #{request.remote_ip}"
      end
      @body = "login single-col"
      render :action => 'new'
    end
  end

  def destroy
    unless @current_person_session.nil?
      @current_person_session.destroy
      flash[:success] = t('success_logout')
    else
      flash[:error] = t('error_already_logged_out')
    end
    custom_logout_url = global_prefs.logout_url.empty? ? root_url : global_prefs.logout_url
    redirect_back_or_default custom_logout_url
  end
  
  def credit_card
    errors = Array.new
    [ :credit_card, :expire, :cvc ].each do |param|
      if params[param].blank?
        errors << "#{param.to_s.humanize} can't be blank"
      end
    end
    if errors.empty?
      stripe_ret = StripeOps.create_customer(params[:credit_card], params[:expire], params[:cvc], current_person.name, current_person.email)

      if stripe_ret.kind_of?(Stripe::Customer)
        current_person.stripe_id = stripe_ret[:id]
        current_person.save!
        redirect_back_or_default home_url
      else
        flash[:error] = stripe_ret
      end
    else
      flash[:error] = errors.join(', ')
    end
  end
end
