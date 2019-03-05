require 'json'

require 'louis/const'
require 'louis/helpers'
require 'louis/version'

module Louis
  # This masks out both the 'universal/local' bit as well as the
  # 'unicast/multicast' bit which is the first and second least significant bit
  # of the first byte in a vendor prefix.
  IGNORED_BITS_MASK = 0xfcffffffffff

  # Loads the lookup table, parsing out the uncommented non-blank lines into
  # objects we can compare MACs against to find their vendor.
  LOOKUP_TABLE = JSON.parse(File.read(Louis::PARSED_DATA_FILE))

  # Collect the recorded mask and order it appropriately from most specific to
  # least.
  #
  # @param [Array<Fixnum>]
  def self.mask_keys
    @mask_keys ||= LOOKUP_TABLE.keys.map(&:to_i).sort.reverse
  end

  # Returns the name of the vendor that has the most specific prefix
  # available in the OUI table or failing any matches will return "Unknown".
  #
  # @param [String] mac
  # @return [String]
  def self.lookup(mac)
    numeric_mac = Louis::Helpers.mac_to_num(mac)
    masked_mac = numeric_mac & IGNORED_BITS_MASK

    vendor = search_table(masked_mac)
    return {'long_vendor' => vendor['l'], 'short_vendor' => vendor['s']}.compact if vendor

    # Try again, but this time don't ignore any bits (Looking at you
    # Google... with your 'da' prefix...)
    vendor = search_table(numeric_mac)
    return {'long_vendor' => vendor['l'], 'short_vendor' => vendor['s']}.compact if vendor

    {'long_vendor' => 'Unknown', 'short_vendor' => 'Unknown'}
  end

  def self.search_table(encoded_mac)
    mask_keys.each do |mask|
      table = LOOKUP_TABLE[mask.to_s]
      prefix = (encoded_mac & Louis::Helpers.calculate_mask(nil, mask)).to_s
      return table[prefix] if table.include?(prefix)
    end

    nil
  end
end
