module Buzzn
  module Utils
    class File
      def self.read(filename)
        data = ::File.read(filename)
        if !data.valid_encoding?
          data = data.unpack('C*').pack('U*')
        end
        data
      end
    end
  end
end
