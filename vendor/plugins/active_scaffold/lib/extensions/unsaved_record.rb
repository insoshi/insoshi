# a simple (manual) unsaved? flag and method. at least it automatically reverts after a save!
class ActiveRecord::Base
  # acts like a dirty? flag, manually thrown during update_record_from_params.
  def unsaved=(val)
    @unsaved = (val) ? true : false
  end

  # whether the unsaved? flag has been thrown
  def unsaved?
    @unsaved
  end

  # automatically unsets the unsaved flag
  def save_with_unsaved_flag(*args)
    result = save_without_unsaved_flag(*args)
    self.unsaved = false
    return result
  end
  alias_method_chain :save, :unsaved_flag
end
