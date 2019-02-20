module Buzzn
  module Utils
    class File

      def self.read(filename)
        data = ::File.read(filename)
        data = data.unpack('C*').pack('U*') unless data.valid_encoding?
        data
      end

      def self.sanitize_filename(filename)
        filename.strip.gsub(/^.*(\\|\/)/, '').gsub(' ', '_').gsub(/[^0-9A-Za-z.\-]/, '_')
      end

    end
  end
end
