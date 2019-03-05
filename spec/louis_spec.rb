require 'spec_helper'

RSpec.describe(Louis) do
  it 'has a version number' do
    expect(Louis::VERSION).not_to be nil
  end

  it 'it should have its source data file' do
    expect(File.readable?(Louis::ORIGINAL_OUI_FILE)).to be(true)
  end

  it 'it should have its parsed data file' do
    expect(File.readable?(Louis::PARSED_DATA_FILE)).to be(true)
  end

  describe 'Original OUI format regex' do
    subject { Louis::OUI_FORMAT_REGEX }

    it 'should ignore comment lines' do
      comment_line = '# This is just a sample of what a comment might look like'
      expect(subject).to_not match(comment_line)
    end

    it 'should ignore blank lines' do
      expect(subject).to_not match('')
    end
  end

  # The core of the whole library
  describe '#lookup' do
    let(:base_mac) { '08:94:ef:00:00:00' }
    let(:partial_mac) { '3c:97:0e' }
    let(:unknown_mac) { 'c5:00:00:00:00:00' }
    let(:local_mac)     { '3e:97:0e' }
    let(:multicast_mac) { '3d:97:0e' }
    let(:multi_match_mac) { 'E4:95:6E:40:00:00'}
    let(:most_specific_match) { 'Guang Lian Zhi Tong Technology Limited'}
    let(:least_specific_match) { 'IEEE Registration Authority'}

    it 'should return a hash' do
      expect(Louis.lookup(base_mac)).to be_a(Hash)
    end

    it 'should have both the long vendor and short vendor' do
      expect(Louis.lookup(base_mac).keys).to eq(['long_vendor', 'short_vendor'])
    end

    it 'should be able to identify the short vendor of a full MAC' do
      expect(Louis.lookup(base_mac)['short_vendor']).to eq('WistronI')
    end

    it 'should be able to identify the long vendor of a full MAC' do
      expect(Louis.lookup(base_mac)['long_vendor']).to eq('Wistron Infocomm (Zhongshan) Corporation')
    end

    it 'should be able to identify the short vendor of a partial MAC' do
      expect(Louis.lookup(partial_mac)['short_vendor']).to eq('WistronI')
    end

    it 'should be able to identify the long vendor of a patrial MAC' do
      expect(Louis.lookup(partial_mac)['long_vendor']).to eq('Wistron InfoComm(Kunshan)Co.,Ltd.')
    end

    it 'should drop the local bit when performing a lookup' do
      expect(Louis.lookup(local_mac)['short_vendor']).to eq('WistronI')
    end

    it 'should drop the multicast bit when performing a lookup' do
      expect(Louis.lookup(multicast_mac)['short_vendor']).to eq('WistronI')
    end

    it 'should return "Unknown" as the short vendor string for unknown MAC prefixes' do
      expect(Louis.lookup(unknown_mac)['short_vendor']).to eq('Unknown')
    end

    it 'should return "Unknown" as the long vendor string for unknown MAC prefixes' do
      expect(Louis.lookup(unknown_mac)['long_vendor']).to eq('Unknown')
    end

    it 'should return the most specific vendor match for MAC prefixes that match multiple mask keys' do
      expect(Louis.lookup(multi_match_mac)['long_vendor']).to_not eq(least_specific_match)
      expect(Louis.lookup(multi_match_mac)['long_vendor']).to eq(most_specific_match)
    end
  end

  # For future reference, these may change and are depedent on the
  # specifications in the data file. These are the slash-suffixes that describe
  # a the relevant bits in the prefix /24 for example.
  describe '#mask_keys' do
    it 'should return a list of integers: [36, 28, 24]' do
      expect(Louis.mask_keys).to eq([36, 28, 24])
    end
  end
end

RSpec.describe(Louis::Helpers) do
  context '#calculate_mask' do
    it 'should prefer the provided mask if one is provided' do
      expect(described_class.calculate_mask('23:45:10', 16)).to eq(0xffff_0000_0000)
    end

    it 'should calculate a bitmask covering the relevant bytes for a provided mac' do
      expect(described_class.calculate_mask('1', nil)).to eq(0xf000_0000_0000)
    end
  end

  context '#clean_mac' do
    it 'should remove colons' do
      expect(described_class.clean_mac('12:34:56:78:9a:bc')).to eq('123456789abc')
    end

    it 'should remove hyphens' do
      expect(described_class.clean_mac('ca-fe-de-ad-be-ef')).to eq('cafedeadbeef')
    end

    it 'should remove periods' do
      expect(described_class.clean_mac('00.00.00.00.00.00')).to eq('000000000000')
    end

    it 'should otherwise leave the mac alone' do
      expect(described_class.clean_mac('001122334455')).to eq('001122334455')
    end
  end

  context '#count_bits' do
    it 'should return the number of set bits in a given number' do
      expect(described_class.count_bits(0b0000_0000)).to eq(0)
      expect(described_class.count_bits(0b0001_1101)).to eq(4)
      expect(described_class.count_bits(0b0101_0101_1111_0000_1100_0011)).to eq(12)
    end
  end

  context '#mac_to_num' do
    it 'should convert the hex representation to an integer' do
      raw_number = 0b11111111_00000000_11111111_00000000_11111111_00000000
      hex_version = raw_number.to_s(16)
      expect(described_class.mac_to_num(hex_version)).to eq(raw_number)
    end

    it 'should left adjust partial MACs before converting to an integer' do
      partial_number = 0b10101010_10101010_10101010.to_s(16)
      full_number = 0b10101010_10101010_10101010_00000000_00000000_00000000
      expect(described_class.mac_to_num(partial_number)).to eq(full_number)
    end
  end

  context '#line_parser' do
    it 'should ignore comments' do
      expect(described_class.line_parser('# something something comment')).to eq(nil)
    end

    it 'should ignore empty lines' do
      expect(described_class.line_parser('')).to eq(nil)
    end

    it 'should handle partial mac prefixes' do
      expect(described_class.line_parser('00:00:10		Sytek	Sytek Inc.')).to eq({
        'mask' => 24,
        'prefix' => 0x0000_1000_0000,
        'long_vendor' => 'Sytek Inc.',
        'short_vendor' => 'Sytek'
      })
    end

    it 'should handle lines with no long name' do
      expect(described_class.line_parser('00:00:17:00:00:00	Oracle')).to eq({
        'mask' => 48,
        'prefix' => 0x000017000000,
        'short_vendor' => 'Oracle'
      })
    end
  end
end
