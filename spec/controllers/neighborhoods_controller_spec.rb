require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NeighborhoodsController do

  def mock_neighborhood(stubs={})
    @mock_neighborhood ||= mock_model(Neighborhood, stubs)
  end

  describe "GET index" do
    it "assigns all neighborhoods as @neighborhoods" do
      Neighborhood.stub!(:find).with(:all).and_return([mock_neighborhood])
      get :index
      assigns[:neighborhoods].should == [mock_neighborhood]
    end
  end

  describe "GET show" do
    it "assigns the requested neighborhood as @neighborhood" do
      Neighborhood.stub!(:find).with("37").and_return(mock_neighborhood)
      get :show, :id => "37"
      assigns[:neighborhood].should equal(mock_neighborhood)
    end
  end

  describe "GET new" do
    it "assigns a new neighborhood as @neighborhood" do
      Neighborhood.stub!(:new).and_return(mock_neighborhood)
      get :new
      assigns[:neighborhood].should equal(mock_neighborhood)
    end
  end

  describe "GET edit" do
    it "assigns the requested neighborhood as @neighborhood" do
      Neighborhood.stub!(:find).with("37").and_return(mock_neighborhood)
      get :edit, :id => "37"
      assigns[:neighborhood].should equal(mock_neighborhood)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created neighborhood as @neighborhood" do
        Neighborhood.stub!(:new).with({'these' => 'params'}).and_return(mock_neighborhood(:save => true))
        post :create, :neighborhood => {:these => 'params'}
        assigns[:neighborhood].should equal(mock_neighborhood)
      end

      it "redirects to the created neighborhood" do
        Neighborhood.stub!(:new).and_return(mock_neighborhood(:save => true))
        post :create, :neighborhood => {}
        response.should redirect_to(neighborhood_url(mock_neighborhood))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved neighborhood as @neighborhood" do
        Neighborhood.stub!(:new).with({'these' => 'params'}).and_return(mock_neighborhood(:save => false))
        post :create, :neighborhood => {:these => 'params'}
        assigns[:neighborhood].should equal(mock_neighborhood)
      end

      it "re-renders the 'new' template" do
        Neighborhood.stub!(:new).and_return(mock_neighborhood(:save => false))
        post :create, :neighborhood => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested neighborhood" do
        Neighborhood.should_receive(:find).with("37").and_return(mock_neighborhood)
        mock_neighborhood.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :neighborhood => {:these => 'params'}
      end

      it "assigns the requested neighborhood as @neighborhood" do
        Neighborhood.stub!(:find).and_return(mock_neighborhood(:update_attributes => true))
        put :update, :id => "1"
        assigns[:neighborhood].should equal(mock_neighborhood)
      end

      it "redirects to the neighborhood" do
        Neighborhood.stub!(:find).and_return(mock_neighborhood(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(neighborhood_url(mock_neighborhood))
      end
    end

    describe "with invalid params" do
      it "updates the requested neighborhood" do
        Neighborhood.should_receive(:find).with("37").and_return(mock_neighborhood)
        mock_neighborhood.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :neighborhood => {:these => 'params'}
      end

      it "assigns the neighborhood as @neighborhood" do
        Neighborhood.stub!(:find).and_return(mock_neighborhood(:update_attributes => false))
        put :update, :id => "1"
        assigns[:neighborhood].should equal(mock_neighborhood)
      end

      it "re-renders the 'edit' template" do
        Neighborhood.stub!(:find).and_return(mock_neighborhood(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested neighborhood" do
      Neighborhood.should_receive(:find).with("37").and_return(mock_neighborhood)
      mock_neighborhood.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the neighborhoods list" do
      Neighborhood.stub!(:find).and_return(mock_neighborhood(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(neighborhoods_url)
    end
  end

end
