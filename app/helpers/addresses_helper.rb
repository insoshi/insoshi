module AddressesHelper
  def privacy_icon(address)
    image_file = address.address_privacy? ? "unlocked.gif" : "locked.gif"
    image_tag "icons/"+image_file, :class => "icon", :alt => "Private"
  end
end
