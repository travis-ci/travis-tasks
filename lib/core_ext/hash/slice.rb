class Hash
  def slice(*keys)
    Hash[*keys.map { |key| [key, self[key]] if key?(key) }.compact.flatten]
  end unless method_defined?(:slice)
end
