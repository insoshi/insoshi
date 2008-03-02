module TestHelper
  def check_ivar_exists(name)
    unless instance_variables.include?(ivar_name = "@#{name}")
      raise "#{ivar_name} does not exist"
    end
  end
end