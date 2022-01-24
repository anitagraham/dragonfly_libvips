require 'test_helper'
require 'ostruct'

describe DragonflyLibvips::Processors::Thumb do
  let(:app) { test_libvips_app }
  let(:image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.png')) } # 280x355
  let(:pdf) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.pdf')) }
  let(:jpg) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.jpg')) }
  let(:cmyk) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample_cmyk.jpg')) }
  let(:gif) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.gif')) }
  let(:anim_gif) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample_anim.gif')) }
  let(:square_crop_tester) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample_colors_square.png')) } # 512x512
  let(:portrait_crop_tester) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample_colors_portrait.png')) } # 512x512
  let(:landscape_crop_tester) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample_colors_landscape.png')) } # 512x512
  let(:landscape_image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('landscape_sample.png')) } # 355x280
  let(:processor) { DragonflyLibvips::Processors::Thumb.new }

  it 'raises an error if an unrecognized string is given' do
    assert_raises(ArgumentError) do
      processor.call(image, '100x100>#ne(')
    end
  end

  describe 'cmyk images' do
    before { processor.call(cmyk, '30x') }
    it { _(cmyk).must_have_width 30 }
  end

  describe 'resizing' do
    describe 'xNN' do
      before { processor.call(landscape_image, 'x30') }
      it { _(landscape_image).must_have_width 38 }
      it { _(landscape_image).must_have_height 30 }
    end

    describe 'NNx' do
      before { processor.call(image, '30x') }
      it { _(image).must_have_width 30 }
      it { _(image).must_have_height 38 }
    end

    describe 'NNxNN' do
      before { processor.call(image, '30x30') }
      it { _(image).must_have_width 24 }
      it { _(image).must_have_height 30 }
    end

    describe 'NNxNN>' do
      describe 'if the image is smaller than specified' do
        before { processor.call(image, '1000x1000>') }
        it { _(image).must_have_width 280 }
        it { _(image).must_have_height 355 }
      end

      describe 'if the image is larger than specified' do
        before { processor.call(image, '30x30>') }
        it { _(image).must_have_width 24 }
        it { _(image).must_have_height 30 }
      end
    end

    describe 'NNxNN<' do
      describe 'if the image is larger than specified' do
        before { processor.call(image, '10x10<') }
        it { _(image).must_have_width 280 }
        it { _(image).must_have_height 355 }
      end

      describe 'if the image is smaller than specified' do
        before { processor.call(image, '500x500<') }
        it { _(image).must_have_width 394 }
        it { _(image).must_have_height 500 }
      end
    end

    describe 'NNxNN!' do
      describe ' ignore aspect ratio' do
        before { processor.call(image, '200x300!') }
        it { _(image).must_have_width 200 }
        it { _(image).must_have_height 300 }
      end
    end

    describe 'NNXNN^' do
      describe 'fill area' do
        before { processor.call(image, '200x300^')}
        it { _(image).must_have_width (300.0 / 355.0 * 280.0).ceil }
        it { _(image).must_have_height 300 }
      end

      describe 'fill area for both dimensions bigger with a different ratio' do
        before { processor.call(image, '500x400^')}
        it { _(image).must_have_width 500 }
        it { _(image).must_have_height (500.0 / 280.0 * 355.0).ceil }
      end

      describe 'fill area square' do
        before { processor.call(image, '100x100^')}
        it { _(image).must_have_width 100 }
        it { _(image).must_have_height (100.0 / 280.0 * 355.0).ceil }
      end
    end
  end

  describe 'cropping' do
    describe 'square' do
      describe 'crop' do
        describe "MMxNN+64+64" do
          before { processor.call(square_crop_tester, '128x128+64+64') }
          it { _(square_crop_tester).must_have_width 128 }
          it { _(square_crop_tester).must_have_height 128 }
          it { _(square_crop_tester).must_have_color_at 10, 10, PINK }
          it { _(square_crop_tester).must_have_color_at 63, 63, TRANSPARENT }
        end

        describe 'MMxNN+10+20, landscape' do
          before { processor.call(square_crop_tester, '70x55+10+20') }
          it { _(square_crop_tester).must_have_width 70 }
          it { _(square_crop_tester).must_have_height 55 }
          it { _(square_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(square_crop_tester).must_have_color_at 69, 54, PINK }
        end

        describe 'MMxNN+10+20, portrait' do
          before { processor.call(square_crop_tester, '55x70+10+20') }
          it { _(square_crop_tester).must_have_width 55 }
          it { _(square_crop_tester).must_have_height 70 }
          it { _(square_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(square_crop_tester).must_have_color_at 54, 69, PINK }
        end
      end

      describe 'crop and resize' do
        describe 'MMxNN#c' do
          before { processor.call(square_crop_tester, '100x100#c') }
          it { _(square_crop_tester).must_have_width 100 }
          it { _(square_crop_tester).must_have_height 100 }
          it { _(square_crop_tester).must_have_color_at(10, 10, PINK) }
          it { _(square_crop_tester).must_have_color_at(10, 60, ORANGE) }
          it { _(square_crop_tester).must_have_color_at(60, 10, PURPLE) }
          it { _(square_crop_tester).must_have_color_at(60, 60, GREEN) }
        end

        describe 'MMxNN#ne, portrait crop' do
          before { processor.call(square_crop_tester, '100x127#ne') }
          it { _(square_crop_tester).must_have_width 100 }
          it { _(square_crop_tester).must_have_height 127 }
          it { _(square_crop_tester).must_have_color_at(10, 10, PINK) }
          it { _(square_crop_tester).must_have_color_at(10, 80, ORANGE) }
          it { _(square_crop_tester).must_have_color_at(60, 10, PURPLE) }
          it { _(square_crop_tester).must_have_color_at(60, 80, GREEN) }
        end
      end
    end

    describe 'landscape' do
      describe 'crop' do
        describe "MMxNN+64+64" do
          before { processor.call(landscape_crop_tester, '128x128+64+64') }
          it { _(landscape_crop_tester).must_have_width 128 }
          it { _(landscape_crop_tester).must_have_height 128 }
          it { _(landscape_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(landscape_crop_tester).must_have_color_at 127, 127, PINK }
        end

        describe 'MMxNN+10+20, landscape' do
          before { processor.call(landscape_crop_tester, '70x55+10+20') }
          it { _(landscape_crop_tester).must_have_width 70 }
          it { _(landscape_crop_tester).must_have_height 55 }
          it { _(landscape_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(landscape_crop_tester).must_have_color_at 69, 54, PINK }
        end

        describe 'MMxNN+10+20, portrait' do
          before { processor.call(landscape_crop_tester, '55x70+10+20') }
          it { _(landscape_crop_tester).must_have_width 55 }
          it { _(landscape_crop_tester).must_have_height 70 }
          it { _(landscape_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(landscape_crop_tester).must_have_color_at 54, 69, PINK }
        end
      end

      describe 'crop and resize' do
        describe 'MMxNN#c' do
          before { processor.call(landscape_crop_tester, '100x100#c') }
          it { _(landscape_crop_tester).must_have_width 100 }
          it { _(landscape_crop_tester).must_have_height 100 }
          it { _(landscape_crop_tester).must_have_color_at(10, 10, PINK) }
          it { _(landscape_crop_tester).must_have_color_at(10, 60, ORANGE) }
          it { _(landscape_crop_tester).must_have_color_at(60, 10, PURPLE) }
          it { _(landscape_crop_tester).must_have_color_at(60, 60, GREEN) }
        end

        describe 'MMxNN#ne, portrait crop' do
          before { processor.call(landscape_crop_tester, '100x127#ne') }
          it { _(landscape_crop_tester).must_have_width 100 }
          it { _(landscape_crop_tester).must_have_height 127 }
          it { _(landscape_crop_tester).must_have_color_at(10, 10, PURPLE) }
          it { _(landscape_crop_tester).must_have_color_at(10, 80, GREEN) }
        end
      end
    end

    describe 'portrait' do
      describe 'crop' do
        describe "MMxNN+64+64" do
          before { processor.call(portrait_crop_tester, '128x128+64+64') }
          it { _(portrait_crop_tester).must_have_width 128 }
          it { _(portrait_crop_tester).must_have_height 128 }
          it { _(portrait_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(portrait_crop_tester).must_have_color_at 127, 127, PINK }
        end

        describe 'MMxNN+10+20, landscape' do
          before { processor.call(portrait_crop_tester, '70x55+10+20') }
          it { _(portrait_crop_tester).must_have_width 70 }
          it { _(portrait_crop_tester).must_have_height 55 }
          it { _(portrait_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(portrait_crop_tester).must_have_color_at 69, 54, PINK }
        end

        describe 'MMxNN+10+20, portrait' do
          before { processor.call(portrait_crop_tester, '55x70+10+20') }
          it { _(portrait_crop_tester).must_have_width 55 }
          it { _(portrait_crop_tester).must_have_height 70 }
          it { _(portrait_crop_tester).must_have_color_at 0, 0, PINK }
          it { _(portrait_crop_tester).must_have_color_at 54, 69, PINK }
        end
      end

      describe 'crop and resize' do
        describe 'MMxNN#c' do
          before { processor.call(portrait_crop_tester, '100x100#c') }
          it { _(portrait_crop_tester).must_have_width 100 }
          it { _(portrait_crop_tester).must_have_height 100 }
          it { _(portrait_crop_tester).must_have_color_at(10, 10, PINK) }
          it { _(portrait_crop_tester).must_have_color_at(10, 60, ORANGE) }
          it { _(portrait_crop_tester).must_have_color_at(60, 10, PURPLE) }
          it { _(portrait_crop_tester).must_have_color_at(60, 60, GREEN) }
        end

        describe 'MMxNN#ne, portrait crop' do
          before { processor.call(portrait_crop_tester, '100x127#ne') }
          it { _(portrait_crop_tester).must_have_width 100 }
          it { _(portrait_crop_tester).must_have_height 127 }
          it { _(portrait_crop_tester).must_have_color_at(10, 10, PINK) }
          it { _(portrait_crop_tester).must_have_color_at(75, 10, PURPLE) }
          it { _(portrait_crop_tester).must_have_color_at(10, 126, ORANGE) }
          it { _(portrait_crop_tester).must_have_color_at(75, 126, GREEN) }
        end
      end
    end
  end

  describe 'pdf' do
    describe 'resize' do
      before { processor.call(pdf, '500x500', format: 'jpg') }
      it { _(pdf).must_have_width 386 }
      it { _(pdf).must_have_height 500 }
    end

    describe 'page param' do
      before { processor.call(pdf, '500x500', format: 'jpg', input_options: { page: 0 }) }
      it { _(pdf).must_have_width 386 }
      it { _(pdf).must_have_height 500 }
    end
  end

  describe 'jpg' do
    describe 'progressive' do
      before { processor.call(jpg, '300x', output_options: { interlace: true }) }
      it { _((`vipsheader -f jpeg-multiscan #{jpg.file.path}`.to_i == 1)).must_equal true }
    end
  end

  describe 'gif' do
    describe 'static' do
      before { processor.call(gif, '200x') }
      it { _(gif).must_have_width 200 }
    end

    describe 'animated' do
      before { processor.call(anim_gif, '200x') }
      it {
        skip 'waiting for full support'
        gif.must_have_width 200
      }
    end
  end

  describe 'format' do
    let(:url_attributes) { OpenStruct.new }

    describe 'when format passed in' do
      before { processor.call(image, '2x2', format: 'jpeg', output_options: { Q: 50 }) }
      it { _(image.ext).must_equal 'jpeg' }
      it { _(image.size).must_be :<, 65_000 }
    end

    describe 'when format not passed in' do
      before { processor.call(image, '2x2') }
      it { _(image.ext).must_equal 'png' }
    end

    describe 'when ext passed in' do
      before { processor.update_url(url_attributes, '2x2', format: 'png') }
      it { _(url_attributes.ext).must_equal 'png' }
    end

    describe 'when ext not passed in' do
      before { processor.update_url(url_attributes, '2x2') }
      it { _(url_attributes.ext).must_be_nil }
    end
  end

  describe 'tempfile has extension' do
    let(:format) { 'jpg' }
    before { processor.call(image, '100x', format: 'jpg') }
    it { _(image.tempfile.path).must_match(/\.jpg\z/) }
  end
end
