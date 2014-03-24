class CDDB::CLI
  def self.usage!
    actions = public_instance_methods(false).map do |m|
      args = instance_method(m).parameters.map do |kind, name|
        case kind
        when :opt;  "[#{name}]"
        when :rest; "#{name} ..."
        else name
        end
      end
      [m, *args].join(' ')
    end

    message = "Usage: #{$0} action [arg ...]\n\n" \
      + "Actions :\n\n" \
      + actions.map { |a| "    #{a}" }.join("\n\n")

    raise ArgumentError, message
  end

  def initialize(cddb, argv)
    @cddb = cddb

    command, *args = argv
    command && respond_to?(command) or self.class.usage!
    begin
      public_send(command, *args)
    rescue ArgumentError => err
      raise unless err.backtrace[0] =~ /:in `#{Regexp.escape command}'/
      raise unless err.message =~ /^wrong number of arguments /
      self.class.usage!
    end
  end

  def find(pattern)
    puts @cddb.find(pattern)
  end

  def complete(pattern)
    puts *@cddb.complete(pattern).map { |p| Format.short_path(p) }
  end

  def list
    print_entries @cddb.entries
  end

  def add(*paths)
    entries = @cddb.add(paths)
    print_entries entries
  end

  def delete(pattern)
    entries = @cddb.delete(pattern)
    print_entries entries
  end

  def prune
    print_entries @cddb.prune
  end

  def gc(max)
    max = max.to_i
    entries = @cddb.gc(max)
    print_entries entries
  end

  def rebuild
    entries = @cddb.rebuild
    print_entries entries
  end

  def clear
    entries = @cddb.clear
    print_entries entries
  end

private

  def print_entries(entries)
    puts *entries.reverse.map { |e| Format.entry e }
  end

  module Format
    YELLOW = "\e[93m"
    GRAY   = "\e[90m"
    RESET  = "\e[39m"

    def self.entry(e)
      diff = Time.now.to_i - e['access']
      dir, basename = File.split(e['path'])
      formatted_diff = "#{YELLOW}#{human_time_diff diff}"
      formatted_path = "#{GRAY}#{short_path dir}/#{RESET}#{basename}"
      "%s\t%s" % [formatted_diff, formatted_path]
    end

    def self.short_path(path)
      path.sub(/^#{Regexp.escape Dir.home}/, '~')
    end

    def self.human_time_diff(diff)
      if    diff > (div = 86400.0)  then "%dd" % [diff / div]
      elsif diff > (div = 3600.0)   then "%dh" % [diff / div]
      elsif diff > (div = 60.0)     then "%dm" % [diff / div]
      else
        "%ds" % diff
      end
    end
  end
end
