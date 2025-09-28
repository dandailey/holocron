# frozen_string_literal: true

require 'fileutils'
require 'colorize'
require 'find'
require 'pathname'
require 'holocron/path_resolver'

module Holocron
  module Commands
    class Notebook < BaseCommand
      def initialize(action, name = nil, file_id = nil, content = nil, options = {})
        super(options)
        @action = action
        @name = name
        @file_id = file_id
        @content = content
      end

      def call
        case @action
        when 'new'
          new_notebook
        when 'status'
          show_status
        when 'add-entry'
          add_entry
        when 'mark-source'
          mark_source
        when 'list'
          list_notebooks
        else
          show_help
        end
      end

      private

      def new_notebook
        require_holocron_directory!
        require_name!

        notebook_path = PathResolver.new(@holocron_directory).resolve_path("notebooks/#{@name}.md")

        if File.exist?(notebook_path)
          puts "❌ Notebook '#{@name}' already exists!".colorize(:red)
          puts "   Use 'holo notebook status #{@name}' to view it".colorize(:yellow)
          exit 1
        end

        # Create notebooks directory if it doesn't exist
        FileUtils.mkdir_p(File.dirname(notebook_path))

        # Read research brief from buffer
        research_brief = read_buffer_content

        # Generate recursive file listing
        sources = generate_sources_list

        # Create the notebook file
        notebook_content = build_notebook_content(@name, research_brief, sources)
        File.write(notebook_path, notebook_content)

        puts "✅ Created notebook: #{notebook_path}".colorize(:green)
        puts "📝 Added #{sources.length} sources to research".colorize(:green)

        # Automatically show status
        show_status
      end

      def show_status
        require_holocron_directory!
        require_name!

        notebook_path = PathResolver.new(@holocron_directory).resolve_path("notebooks/#{@name}.md")

        unless File.exist?(notebook_path)
          puts "❌ Notebook '#{@name}' not found!".colorize(:red)
          puts "   Use 'holo notebook new --from-buffer --name #{@name}' to create it".colorize(:yellow)
          exit 1
        end

        puts "📓 Notebook: #{notebook_path}".colorize(:cyan)
        puts

        # Parse the notebook to show sources and progress
        content = File.read(notebook_path, encoding: 'UTF-8')
        sources_section = extract_sources_section(content)

        if sources_section
          puts '## Sources to Research'.colorize(:yellow)
          puts sources_section
          puts

          # Count completed sources
          completed = sources_section.scan(/^- \[x\]/).length
          total = sources_section.scan(/^- \[[ x]\]/).length

          puts "Progress: #{completed}/#{total} sources completed".colorize(:green)
          puts
        end

        puts "Next action: Run 'holo notebook add-entry #{@name} <file-id> <content>' on a file from the list above".colorize(:cyan)
      end

      def add_entry
        require_holocron_directory!
        require_name!
        require_file_id!

        notebook_path = PathResolver.new(@holocron_directory).resolve_path("notebooks/#{@name}.md")

        unless File.exist?(notebook_path)
          puts "❌ Notebook '#{@name}' not found!".colorize(:red)
          exit 1
        end

        # Read current content
        content = File.read(notebook_path, encoding: 'UTF-8')

        # Find the source file path for this file_id
        source_path = find_source_path(content, @file_id)
        unless source_path
          puts "❌ File ID '#{@file_id}' not found in notebook!".colorize(:red)
          exit 1
        end

        # Mark the source as completed
        updated_content = mark_source_completed(content, @file_id)

        # Add the new entry
        entry = build_entry(@file_id, source_path, @content, notebook_path)
        updated_content += "\n\n#{entry}"

        # Write back to file
        File.write(notebook_path, updated_content)

        puts "✅ Added entry for file #{@file_id}: #{source_path}".colorize(:green)
        puts '📝 Updated notebook with research notes'.colorize(:green)
      end

      def mark_source
        require_holocron_directory!
        require_name!
        require_file_id!

        notebook_path = PathResolver.new(@holocron_directory).resolve_path("notebooks/#{@name}.md")

        unless File.exist?(notebook_path)
          puts "❌ Notebook '#{@name}' not found!".colorize(:red)
          exit 1
        end

        # Read current content
        content = File.read(notebook_path, encoding: 'UTF-8')

        # Find the source file path for this file_id
        source_path = find_source_path(content, @file_id)
        unless source_path
          puts "❌ File ID '#{@file_id}' not found in notebook!".colorize(:red)
          exit 1
        end

        # Determine current status and toggle
        current_status = source_completed?(content, @file_id)
        new_status = current_status ? 'incomplete' : 'complete'

        # Update the source status
        updated_content = toggle_source_status(content, @file_id)

        # Write back to file
        File.write(notebook_path, updated_content)

        puts "✅ Marked file #{@file_id} (#{source_path}) as #{new_status}".colorize(:green)
      end

      def list_notebooks
        require_holocron_directory!

        path_resolver = PathResolver.new(@holocron_directory)
        notebooks_dir = path_resolver.resolve_path('notebooks')

        unless Dir.exist?(notebooks_dir)
          puts '📓 No notebooks found'.colorize(:yellow)
          puts "   Use 'holo notebook new --from-buffer --name <name>' to create one".colorize(:cyan)
          return
        end

        notebooks = Dir.glob(File.join(notebooks_dir, '*.md')).map { |f| File.basename(f, '.md') }

        if notebooks.empty?
          puts '📓 No notebooks found'.colorize(:yellow)
          puts "   Use 'holo notebook new --from-buffer --name <name>' to create one".colorize(:cyan)
          return
        end

        puts '📓 Available Notebooks:'.colorize(:cyan)
        puts

        notebooks.each do |notebook_name|
          notebook_path = File.join(notebooks_dir, "#{notebook_name}.md")
          content = File.read(notebook_path, encoding: 'UTF-8')

          # Count progress
          sources_section = extract_sources_section(content)
          if sources_section
            completed = sources_section.scan(/^- \[x\]/).length
            total = sources_section.scan(/^- \[[ x]\]/).length
            progress = "#{completed}/#{total}"
          else
            progress = '0/0'
          end

          puts "  • #{notebook_name} (#{progress})".colorize(:white)
          puts "    #{notebook_path}".colorize(:gray)
        end
      end

      def show_help
        puts '📓 Holocron Notebook Commands:'.colorize(:cyan)
        puts
        puts '  holo notebook new --from-buffer --name <name>     Create a new notebook'.colorize(:white)
        puts '  holo notebook status <name>                      Show notebook status and sources'.colorize(:white)
        puts '  holo notebook add-entry <name> <file-id> <content>  Add research entry'.colorize(:white)
        puts '  holo notebook mark-source <name> <file-id>       Toggle source completion status'.colorize(:white)
        puts '  holo notebook list                               List all notebooks'.colorize(:white)
        puts
        puts 'Use --from-buffer flag to read content from tmp/buffer'.colorize(:yellow)
      end

      def read_buffer_content
        path_resolver = PathResolver.new(@holocron_directory)
        buffer_path = path_resolver.resolve_path('tmp/buffer')

        unless File.exist?(buffer_path)
          FileUtils.mkdir_p(File.dirname(buffer_path))
          File.write(buffer_path, '')
          puts 'Error: Buffer file was empty, created new one'.colorize(:red)
          puts 'Add content to tmp/buffer first'.colorize(:yellow)
          exit 1
        end

        content = File.read(buffer_path, encoding: 'UTF-8')
        if content.strip.empty?
          puts 'Error: Buffer file is empty'.colorize(:red)
          puts 'Add content to tmp/buffer first'.colorize(:yellow)
          exit 1
        end

        content
      end

      def generate_sources_list
        sources = []
        Find.find(@holocron_directory) do |path|
          next if File.directory?(path)
          next if path.include?('/.git/')
          next if path.include?('/node_modules/')
          next if path.include?('/notebooks/') # Don't include other notebooks

          relative_path = Pathname.new(path).relative_path_from(Pathname.new(@holocron_directory))

          # Get file metadata
          stat = File.stat(path)
          size_kb = (stat.size / 1024.0).round(1)
          mtime = stat.mtime.strftime('%Y-%m-%d')
          file_type = File.extname(path).sub('.', '') || 'text'

          # Format: "path (size, date, type)"
          sources << {
            path: relative_path.to_s,
            size: size_kb,
            mtime: mtime,
            type: file_type
          }
        end

        sources.sort_by { |s| s[:path] }
      end

      def build_notebook_content(name, research_brief, sources)
        title = name.split('_').map(&:capitalize).join(' ')

        content = <<~CONTENT
          # #{title}

          ## Research Brief
          #{research_brief}

          **Note**: Content in the research brief should use H3 headers (###) or lower to maintain clean hierarchy.

          ## Sources to Research
        CONTENT

        sources.each_with_index do |source, index|
          file_id = format('%04d', index + 1)
          content += "- [ ] #{file_id}: #{source[:path]} (#{source[:size]}KB, #{source[:mtime]}, #{source[:type]})\n"
        end

        content += "\n## Research Notes\n\n"

        content
      end

      def extract_sources_section(content)
        # Extract the sources section from the notebook content
        match = content.match(/## Sources to Research\n(.*?)\n## Research Notes/m)
        match ? match[1] : nil
      end

      def find_source_path(content, file_id)
        sources_section = extract_sources_section(content)
        return nil unless sources_section

        # Look for the file_id in the sources list
        sources_section.lines.each do |line|
          return ::Regexp.last_match(1).strip if line.match(/^- \[[ x]\] #{file_id}: (.+?) \(/)
        end

        nil
      end

      def mark_source_completed(content, file_id)
        # Replace [ ] with [x] for the specific file_id
        content.gsub(/^- \[ \] #{file_id}:/, "- [x] #{file_id}:")
      end

      def source_completed?(content, file_id)
        # Check if the source is marked as completed
        sources_section = extract_sources_section(content)
        return false unless sources_section

        sources_section.lines.any? { |line| line.match(/^- \[x\] #{file_id}:/) }
      end

      def toggle_source_status(content, file_id)
        # Toggle between [ ] and [x] for the specific file_id
        content.gsub(/^- \[([ x])\] #{file_id}:/) do |match|
          current_status = ::Regexp.last_match(1)
          new_status = current_status == ' ' ? 'x' : ' '
          "- [#{new_status}] #{file_id}:"
        end
      end

      def build_entry(file_id, source_path, content, notebook_path)
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

        # Calculate relative path from notebook to source
        notebook_dir = File.dirname(notebook_path)
        holocron_dir = @holocron_directory
        full_source_path = File.join(holocron_dir, source_path)
        relative_path = Pathname.new(full_source_path).relative_path_from(Pathname.new(notebook_dir))

        <<~ENTRY
          #### #{file_id}: #{File.basename(source_path)}
          **Source:** [#{source_path}](#{relative_path})
          **Timestamp:** #{timestamp}

          #{content}
        ENTRY
      end

      def require_name!
        return if @name

        puts '❌ Notebook name is required!'.colorize(:red)
        puts "   Use: holo notebook #{@action} <name>".colorize(:yellow)
        exit 1
      end

      def require_file_id!
        return if @file_id

        puts '❌ File ID is required!'.colorize(:red)
        puts '   Use: holo notebook add-entry <name> <file-id> <content>'.colorize(:yellow)
        exit 1
      end
    end
  end
end
