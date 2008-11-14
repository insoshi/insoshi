# the ever-useful to_label method
class ActiveRecord::Base
  def to_label
    [:name, :label, :title, :to_s].each do |attribute|
      return send(attribute).to_s if respond_to?(attribute)
    end
  end
end
