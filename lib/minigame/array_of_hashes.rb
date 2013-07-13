module ArrayOfHashes
  include Enumerable

  def initialize(*array_of_hashes)
    array_of_hashes = [array_of_hashes].flatten
    @keys ||=[]
    # checks to see if required_keys was called 
    # as a singleton method on the included class
    @keys = self.class.keys if self.class.keys
    check_array(array_of_hashes)
    @array_of_hashes=array_of_hashes
  end

  def each(&block)
    @array_of_hashes.each do |matchup|
      block.call(matchup)
    end
  end

  # creates a singleton method on the included class
  # which avoids having to put 'required_keys' into the 
  # included classes initialize method
  def self.included(klass)
    class << klass
      attr_accessor :keys
      def required_keys(*keys)
        # force single keys to be an array
        keys = [keys].flatten
        keys.each do |x|
          raise 'Not a symbol' if !keys[0].is_a? Symbol
        end
        @keys=keys
      end
    end
  end

  # required keys available on the instance 
  def required_keys(*keys)
    # force single keys to be an array
    keys = [keys].flatten
    keys.each do |x|
      raise 'Not a symbol' if !keys[0].is_a? Symbol
    end
    @keys = keys
  end

  def required_keys=(keys)
    required_keys(keys)
  end

  def check_array(array_of_hashes)
    raise 'Not an array' if !array_of_hashes.is_a? Array
    array_of_hashes.each{|x|check_keys(x)}
  end
  
  def check_keys(val)
    raise "Not a Hash" if val.class != Hash 
    @keys.each do |x|
      raise "#{x.to_s.capitalize} required" if !val.keys.include?(x)
    end
  end

  def <<(val)
    check_keys(val)
    @array_of_hashes << val
  end

end
