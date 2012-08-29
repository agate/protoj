class ProtoJ::Utils
  def self.to_sorted_hash(hash)
    if hash.is_a? Hash
      hash = Hash[hash.sort]
      hash.each_pair do |k,v|
        hash[k] = to_sorted_hash(v)
      end
      return hash
    elsif hash.is_a? Array
      return hash.collect do |item|
        to_sorted_hash(item)
      end
    else
      return hash
    end
  end

  def self.to_sorted_json(json)
    to_sorted_hash(JSON.parse(json)).to_json
  end
end
