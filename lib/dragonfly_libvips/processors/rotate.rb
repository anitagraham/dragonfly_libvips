require 'vips'
require 'dragonfly_libvips/processors'

module DragonflyLibvips
  module Processors
    class Rotate
      include DragonflyLibvips::Processors

      def call(*args, **options)
        content, degrees = args
        wrap_process(content, **options) do |img|
          img = img.rot("d#{degrees}")
        end
      end
    end
  end
end
