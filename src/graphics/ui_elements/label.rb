# frozen_string_literal: true

module UIElements
  # Represents a label
  class Label < UIElement
    include Resources
    include MouseEvents
    include SelectionEvents

    attr_reader :image, :value, :color

    def initialize(window, x, y, options)
      super(window, x, y, options)
      parse(options)
      init_mouse_events
    end

    def draw(image_opts = {}, text_opts = {})
      @drawing[:image].merge!(image_opts) unless image_opts.nil?
      @drawing[:text].merge!(text_opts) unless text_opts.nil?
      draw_image
      draw_markup(@drawing[:text])
    end

    def update(*); end

    def value=(value)
      @value = value
      normalize_text
    end

    def color=(color)
      @drawing[:text][:color] = color
    end

    def set_size(width, height)
      @width = width
      @height = height
    end

    def add_image(image)
      @image = image
      return if image.width <= @width && image.height <= @height
      @image = image.subimage(0, 0, @width, @height)
    end

    def add_text(options = {})
      @value = options[:value] || ''
      @font = options[:font] || Textures.get(:default_font)
    end

    protected

    def parse(options = {})
      set_size(options[:width] || 100, options[:height] || 50)
      add_image(options[:image] || Textures.get(:default_label))
      add_text(options[:text])
      add_drawing(options)
    end

    def add_drawing(options)
      @drawing = {}
      @drawing[:text] = @drawing[:image] = {}
      add_drawing_normalization(options)
      add_drawing_alignment(options)
    end

    def draw_image(image_opts = {})
      @image.draw(@x,
                  @y,
                  @z,
                  image_opts[:scale_x] || 1.0,
                  image_opts[:scale_y] || 1.0,
                  image_opts[:color] || WHITE,
                  image_opts[:mode] || :default)
    end

    def draw_markup(text_opts = {})
      @font.draw_markup_rel(@value,
                            @x + text_opts[:x_offset],
                            @y + text_opts[:y_offset],
                            ZOrder::UIOrder::LABEL_TEXT,
                            text_opts[:rel_x],
                            text_opts[:rel_y],
                            text_opts[:scale_x] || 1.0,
                            text_opts[:scale_y] || 1.0,
                            text_opts[:color] || WHITE,
                            text_opts[:mode] || :default)
    end

    def normalize_text
      text_width = @font.markup_width(@value)
      if (text_width - @width).positive?
        @drawing[:text][:scale_x] = 1.0 / (text_width / @width)
      end
      return unless (@font.height - @height).positive?
      @drawing[:text][:scale_y] = 1.0 / (@font.height / @height)
    end

    def compute_aligning(align = :left)
      alignment = { top_left: [0.0, 0.0, 0.0, 0.0],
                    top: [0.5, 0.0, @width / 2, 0.0],
                    top_right: [1.0, 0.0, @width, 0.0],
                    left: [0.0, 0.5, 0.0, @height / 2],
                    center: [0.5, 0.5, @width / 2, @height / 2],
                    right: [1.0, 0.5, @width, @height / 2],
                    bottom_left: [0.0, 1.0, 0.0, @height],
                    bottom: [0.5, 1.0, @width / 2, @height],
                    bottom_right: [1.0, 1.0, @width, @height] }
      alignment[align.to_sym]
    end

    def add_drawing_normalization(options)
      options[:text][:normalize] ||= true
      return unless options[:text][:normalize]
      normalize_text
    end

    def add_drawing_alignment(options)
      @drawing[:text][:rel_x], @drawing[:text][:rel_y],
      @drawing[:text][:x_offset], @drawing[:text][:y_offset] =
        compute_aligning(options[:text][:align] || :left)
    end
  end
end
