class Grape::Util::HashStack
  def method_missing(method_name, *arguments, &block)
    result = get(method_name)
  end
end
