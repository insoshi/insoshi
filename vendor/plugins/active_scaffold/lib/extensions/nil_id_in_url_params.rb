class ActionController::Routing::RouteSet
  def generate_with_nil_id_awareness(*args)
    args[0].delete(:id) if args[0][:id].nil?
    generate_without_nil_id_awareness(*args)
  end
  alias_method_chain :generate, :nil_id_awareness
end