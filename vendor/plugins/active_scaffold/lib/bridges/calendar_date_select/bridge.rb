ActiveScaffold.bridge "CalendarDateSelect" do
  install do
    # check to see if the old bridge was installed.  If so, warn them
    # we can detect this by checking to see if the bridge was installed before calling this code
    if ActiveScaffold::Config::Core.instance_methods.include?("initialize_with_calendar_date_select")
      raise RuntimeError, "We've detected that you have active_scaffold_calendar_date_select_bridge installed.  This plugin has been moved to core.  Please remove active_scaffold_calendar_date_select_bridge to prevent any conflicts"
    end
    
    require File.join(File.dirname(__FILE__), "lib/as_cds_bridge.rb")
  end
end
