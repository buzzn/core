module Buzzn
  module Util
    class File
      def self.read(filename)
        data = ::File.read(filename)
        data.match /\r?\n/ # it bails out on corrupted utf-8
        data
      rescue ArgumentError
        # first assume data is in utf-8 now fall back to latin-1
        data.force_encoding(Encoding::ISO_8859_1)
      end
    end
  end
end
