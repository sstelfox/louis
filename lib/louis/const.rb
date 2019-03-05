module Louis
  ORIGINAL_OUI_FILE = File.expand_path(File.join(File.dirname(__FILE__), \
    '..', '..', 'data', 'mac_oui_manuf.txt')).freeze

  PARSED_DATA_FILE = File.expand_path(File.join(File.dirname(__FILE__), \
    '..', '..', 'data', 'processed_data.json')).freeze

  OUI_FORMAT_REGEX = /^(?<prefix>[0-9a-fA-F:\-.]+)(\/(?<mask>(\d+)))?\s+(?<short_vendor>\S+)(\s+(?<long_vendor>.+))?$/.freeze
end
