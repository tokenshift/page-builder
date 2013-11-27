require_relative 'layout'

module PageBuilder
  class Folder
    def options
      @options ||= {
        kramdown: {}
      }
    end

    attr_reader :files, :folders, :root

    def initialize(root, layouts = {})
      @root = File.expand_path(root)
      @layouts = layouts.clone

      entries = Dir.entries(root).reject { |filename|
        filename.start_with? "."
      }

      @content_files = {}
      @folders = {}

      entries.each do |e|
        filename = File.join(root, e)
        unless File.directory? filename
          if e.include? "_layout."
            name = /\A(.*)_layout\..*\Z/.match(e)[1]
            @layouts[name] = Layout.new(filename)
          elsif Layout.can_render_content? filename
            @content_files[e] = File.stat(filename)
          end
        end
      end

      entries.each do |e|
        filename = File.join(root, e)
        if File.directory? filename
          folders[e] = Folder.new(filename, @layouts)
        end
      end
    end

    def content_files
      @content_files
    end

    # Sets the heading level offset of rendered content.
    def heading_offset(level = 1)
      orig_level = options[:kramdown][:header_offset]
      begin
        options[:kramdown][:header_offset] = level
        yield if block_given?
      ensure
        if block_given?
          if orig_level.nil?
            options[:kramdown].delete(:header_offset)
          else
            options[:kramdown][:header_offset] = orig_level
          end
        end
      end
    end

    # Gets the most recently created content file.
    def latest
      content_files.sort_by { |name, stat| stat.ctime }.last
    end

    # Renders a piece of content using the specified layout.
    def layout(name, &content)
      layout = @layouts[name]
      raise "Layout not found: #{name}" if layout.nil?

      layout.render_block(self, content)
    end

    def process
      puts "Processing folder #{root}"

      content_files.each do |name, stat|
        puts "Rendering #{root}/#{name}"
        if name.start_with? "_"
          Layout.no_layout.render(self, name)
        else
          current_layout.render(self, name)
        end
      end

      folders.each do |name, folder|
        folder.process
      end
    end

    # Renders the specified content file without any layout.
    def render(target)
      filename = nil
      if target.is_a? String
        filename = target
      elsif target.is_a? Array
        filename = target[0]
      end

      raise "Cannot render #{target}" if filename.nil?

      puts "Local rendering #{filename} from #{root}"
      Layout.no_layout.render_content(self, filename)
    end

    private

    def current_layout
      @current_layout ||= @layouts.values.last || Layout.no_layout
    end
  end
end
