require 'kramdown'
require 'slim'

module PageBuilder
  class Layout
    def self.no_layout
      @@no_layout ||= Layout.new
    end

    def self.content_processors
      @@content_processors ||= {}
    end

    def self.layout_processors
      @@layout_processors ||= {}
    end

    def self.can_render_content?(filename)
      @@content_processors.has_key? File.extname(filename)
    end

    def self.can_render_layout?(filename)
      @@layout_processors.has_key? File.extname(filename)
    end

    def initialize(filename = nil)
      @filename = filename

      if filename.nil?
        @layout_proc = Proc.new do |context, content_proc|
          content_proc.call
        end
      else
        in_type = File.extname filename

        processor = Layout.layout_processors[in_type]
        raise "Unsupported layout type: #{in_type}" if processor.nil?

        File.open(filename) do |f|
          @layout_proc = processor.call(f)
        end
      end
    end

    # Renders a content file to the appropriate output file.
    def render(context, filename)
      puts "Layout #{@filename} rendering #{filename}"
      ext = File.extname filename

      out_filename = File.basename(filename, ext)
      out_filename = out_filename.gsub(/\A_/, "")
      out_filename = File.join(context.root, out_filename)

      content_proc = Proc.new do
        render_content(context, filename)
      end

      File.open(out_filename, "w") do |f|
        f.write render_block(context, content_proc)
      end
    end

    # Renders content given as a block in the current layout.
    def render_block(context, content)
      puts "Layout #{@filename} rendering content block"
      @layout_proc.call(context, content)
    end

    # Renders a content file (without layout) to a string.
    def render_content(context, filename)
      puts "Rendering content file #{filename}"

      in_type = File.extname filename
      in_filename = File.join(context.root, filename)

      processor = Layout.content_processors[in_type]
      raise "Unsupported content type: #{in_type}" if processor.nil?

      File.open(in_filename) do |f|
        processor.call(context, f)
      end
    end
  end

  Layout.content_processors[".md"] = Proc.new do |context, file|
    Kramdown::Document.new(file.read, context.options[:kramdown]).to_html
  end

  Layout.content_processors[".slim"] = Proc.new do |context, file|
    context.instance_eval(Slim::Engine.new.call(file.read))
  end

  def eval_template(context, source)
    context.instance_eval(source)
  end

  Layout.layout_processors[".slim"] = Proc.new do |file|
    source = Slim::Engine.new.call(file.read)
    Proc.new do |context, content_proc|
      eval_template(context, source) {
        content_proc.call
      }
    end
  end
end

Slim::Engine.set_default_options(
  pretty: true,
  sort_attrs: false,
  disable_escape: true)
