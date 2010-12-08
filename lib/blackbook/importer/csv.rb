require 'fastercsv'

##
# Imports contacts from a CSV file

class Blackbook::Importer::Csv < Blackbook::Importer::Base

  DEFAULT_COLUMNS = [:name,:email,:misc]

  ##
  # Matches this importer to a file that contains CSV values

  def =~(options)
    options && options[:file].respond_to?(:open) ? true : false
  end

  ##
  # fetch_contacts! implementation for this importer

  def fetch_contacts!
    lines = IO.readlines(options[:file].path)
    columns = to_columns(lines.first)

    # if first cell contains the word name, assume it's a header column
    if columns.first.to_s =~ /name/i
      lines.shift
    else
      columns = DEFAULT_COLUMNS.dup
    end

    contacts = Array.new
    lines.each do |l|
      vals = l.split(',')
      next if vals.empty?
      contacts << to_hash(columns, vals)
    end

    contacts
  end

  def to_hash(cols, vals) # :nodoc:
    h = Hash.new
    cols.each do |c|
      h[c] = (c == cols.last) ? vals.join(',') : vals.shift
    end
    h
  end

  def to_columns(line) # :nodoc:
    columns = Array.new
    tags = line.split(',')
    tags.each do |v|
      # match outlook, outlook express, or thunderbird
      if v =~ /^name$/i or v =~ /^Display Name$/i
        columns << :name
      elsif v =~ /^e.?mail/i or v =~ /^E.?mail Address$/i or v =~ /^Primary Email$/i
        columns << :email
      elsif !v.strip.blank?
        columns << v.strip.to_sym
      end
    end
    columns
  end

  Blackbook.register(:csv, self)
end