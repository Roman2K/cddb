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
    puts *@cddb.complete(pattern)
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
    puts *Format.entries(entries.reverse)
  end

  module Format
    def self.entries(entries)
      max = entries.map { |e| e['name'].length }.max
      entries.map do |e|
        diff = Time.now.to_i - e['access']
        "%s\t%-*s\t%s" % [human_time_diff(diff), max, e['name'], e['path']]
      end
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
