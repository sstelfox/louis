module Louis
  module Helpers
    # Calculate the bit mask for testing whether or not a mac_prefix matches.
    # This returns an integer with the upper X bits set where X is the mask
    # length.
    #
    # @param [String] prefix
    # @param [String] mask
    # @return [Fixnum]
    def self.calculate_mask(prefix, mask)
      mask_base = mask.nil? ? (clean_mac(prefix).length * 4) : mask.to_i
      (2 ** 48 - 1) - (2 ** (48 - mask_base) - 1)
    end

    # Returns the hex representing a full or partial MAC address with the
    # 'connecting' characters removed. Does nothing to ensure length.
    #
    # @param [String] mac
    # @return [String]
    def self.clean_mac(mac)
      mac.tr(':\.-', '')
    end

    # Count the number of bits set in an integer. This likely could use an
    # improved algorithm but this is fast and effective enough.
    #
    # @param [Fixnum] num
    # @return [Fixnum]
    def self.count_bits(num)
      num.to_s(2).count('1')
    end

    # Converts a hexidecimal version of a full or partial (prefix) MAC address
    # into it's integer representation.
    #
    # @param [String] mac
    def self.mac_to_num(mac)
      clean_mac(mac).ljust(12, '0').to_i(16)
    end

    # Handle parsing a line from the raw OUI file into it's associated lookup
    # table format. This will return nil if the line is poorly formatted, empty
    # or a comment.
    #
    # @param [String]
    # @return [Hash<String=>Object>]
    def self.line_parser(line)
      return unless (matches = OUI_FORMAT_REGEX.match(line))
      result = Hash[matches.names.zip(matches.captures)]

      mask = calculate_mask(result['prefix'], result['mask'])
      prefix = mac_to_num(result['prefix']) & mask

      {
        'mask'         => count_bits(mask),
        'prefix'       => prefix,
        'long_vendor'  => result['long_vendor'],
        'short_vendor' => result['short_vendor']
      }.reject { |_, v| v.nil? }
    end
  end
end
