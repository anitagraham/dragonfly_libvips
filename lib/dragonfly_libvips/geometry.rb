module DragonflyLibvips

  class Geometry < Struct.new(:geom_w, :geom_h, :x_offset, :y_offset, :modifiers, :area, :gravity, keyword_init: true)
    def self.call(geometry)
      new.call(geometry)
    end

    def call(geometry)
      case geometry
        when thumb_geometry
          matches = geometry.match(thumb_geometry).named_captures.compact

          %w[geom_w geom_h x_offset y_offset area].each do |key|
            m = matches.fetch(key, nil)
            m = m.to_i unless m.nil?
            matches[key] = m
          end

          matches
        else raise ArgumentError, "Didn't recognise the geometry string: #{geometry}"
      end
    end

    def thumb_geometry
      Regexp.union(RESIZE_GEOMETRY,
                   CROPPED_RESIZE_GEOMETRY,
                   CROP_GEOMETRY)
    end
  end
end
