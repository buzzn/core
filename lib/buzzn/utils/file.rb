module Buzzn
  module Utils
    class File
      def self.read(filename)
        data = ::File.read(filename)
        data = data.unpack('C*').pack('U*') unless data.valid_encoding?
        data
      end
    end
  end
end
