require 'fileutils'
require 'json'

class CDDB
  autoload :CLI, 'cddb/cli'

  def initialize(path)
    @path = path
    @last_update = current_update_time
    @entries = parse_entries
  end

  attr_reader :entries

  def find(pattern)
    if File.directory?(path = pattern)
      path = File.expand_path(path)
      if entry = @entries.find { |e| e['path'] == path }
        touch entry
      else
        entry = add_entry path
      end
    elsif entry = matches(pattern).first
      touch entry
    end
    return pattern unless entry
    entry['path']
  end

  def add(paths)
    paths = paths.select { |p| File.directory? p }.map { |p| File.expand_path p }
    existing = @entries.map { |e| e['path'] }
    (paths - existing).map do |path|
      add_entry path
    end
  end

  def delete(pattern)
    to_delete = matches(pattern).to_a
    @entries -= to_delete
    save
    to_delete
  end

  def prune
    before = @entries.dup
    @entries.
      delete_if { |e| !File.directory?(e['path']) }.
      uniq! { |e| e['path'] }
    save
    before - @entries
  end

  def gc(max)
    max = [max, 0].max
    before = @entries.dup
    @entries.slice! max..-1
    save
    before - @entries
  end

  def complete(pattern)
    glob = pattern.sub('~', Dir.home) + '*/'
    matches(pattern).map { |e| e['path'] }.to_a.
      concat(Dir.glob(glob).map { |p| p.chomp('/') }).
      uniq
  end

  def rebuild
    paths = @entries.map { |e| e['path'] }
    @entries.clear
    add paths
    save
    @entries
  end

  def clear
    before = @entries.dup
    @entries.clear
    save
    before
  end

private

  def current_update_time
    return nil unless File.file? @path
    File.mtime @path
  end

  def parse_entries
    return [] unless File.file? @path
    File.open @path, 'rb' do |f|
      JSON.load f
    end
  end

  def matches(pattern)
    matcher = Regexp.new(pattern.each_char.to_a.join('.*'), 'i')
    @entries.lazy.select { |e| matcher === e['path'] }
  end

  def add_entry(path)
    entry = {
      'path' => File.expand_path(path),
      'access' => Time.now.to_i,
    }
    @entries << entry
    save
    entry
  end

  def touch(entry)
    entry['access'] = Time.now.to_i
    save
  end

  def save
    @entries.sort_by! { |e| -e['access'] }
    if current_update_time != @last_update
      raise "DB has been updated by someone else, won't overwrite"
    end
    File.open @path, 'wb' do |f|
      JSON.dump @entries, f
    end
    @last_update = current_update_time
  end
end
