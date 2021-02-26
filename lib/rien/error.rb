# frozen_string_literal: true

module Rien
  module Error
    class BassError < RuntimeError
      attr_reader :path, :reason

      def initialize(operation, path, reason)
        @path = path
        @reason = reason

        super(+"failed to #{operation} -- #{path}, reason: #{reason}")
      end
    end

    class FailedToEncode < BassError
      def initialize(path, reason)
        super('encode', path, reason)
      end
    end

    class FailedToMove < BassError
      def initialize(path, reason)
        super('move', path, reason)
      end
    end

    class FailedToCopy < BassError
      def initialize(path, reason)
        super('copy', path, reason)
      end
    end

    class FailedToLoadRienfile < BassError
      def initialize(path, reason)
        super('load Rienfile', path, reason)
      end
    end
  end
end
