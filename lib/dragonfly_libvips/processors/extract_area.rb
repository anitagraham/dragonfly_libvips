require 'vips'
require 'dragonfly_libvips/processors'

module DragonflyLibvips
  module Processors
    class ExtractArea
      include DragonflyLibvips::Processors

      def call( *args, **options)
        content, x, y, width, height, others = args
        options = {**options, **others} if others.is_a? Hash
        wrap_process(content,  **options) do |img |
          img = img.extract_area(x, y, width, height)
        end
      end
    end
  end
end
