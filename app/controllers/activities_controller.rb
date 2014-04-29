class ActivitiesController < ApplicationController

  before_filter :authorize_user, :only => :destroy
  before_filter :credit_card_required

  # This gets called after activity destruction for some reason.
  def show
    render :text => ""
  end

  # DELETE /activities/1
  # DELETE /activities/1.xml
  def destroy
    @activity.destroy
    flash[:success] = t("success_activity_deleted")

    respond_to do |format|
      format.html { redirect_to(person_url(current_person)) }
      format.xml  { head :ok }
    end
  end

  private

    def authorize_user
      @activity = Activity.find(params[:id])
      unless current_person?(@activity.person)
        redirect_to home_url
      end
    end

end
