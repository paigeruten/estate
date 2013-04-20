# estate.rb
# the erector of _why's Estate

$:.unshift '.'

require 'fileutils'

unless (2..3) === ARGV.length
  puts "Usage: ruby estate.rb [--index-only] <indir> <outdir>"
  exit
end

if ARGV.length == 3
  if ARGV[0] == "--index-only"
    index_only = true
    dir_in = ARGV[1]
    dir_out = ARGV[2]
  else
    puts "`#{ ARGV[0] }' isn't a valid option!"
    exit
  end
else
  index_only = false
  dir_in = ARGV[0]
  dir_out = ARGV[1]
end

#
# helper functions for HTML output
#

module HTML
  NBSP = "&nbsp;"

  # <a href="...">
  def a(text, url)
    "<a href=\"#{url}\">#{text}</a>"
  end

  # <span class="...">
  def span(klass, text)
    "<span class=\"#{klass}\">#{text}</span>"
  end

  # <p>, <h1>, <h3>, <li>
  [:p, :h1, :h3, :li].each do |tag|
    # lone & neat
    define_method(tag) { |text| "<#{tag}>#{text}</#{tag}>\n" }

    # with id attribute
    define_method("#{tag.to_s}_id") do |id, text|
      "<#{tag} id=\"#{id}\">#{text}</#{tag}>\n"
    end
  end
end

include HTML

#
# function that interpolates variables in header.html
#

def interpolate_header(text, title, dir)
  text = text.gsub("{title}", title)
  text = text.gsub("{dir}", dir)

  text
end

#
# class to make the HTML list
#

class Estate
  def initialize
    @footnote = 1
    @notes = []
  end

  def make_list(list, horizontal = false, quiet = false)
    if horizontal
      out = ": "
    else
      out = "<ul>"
    end

    list.each do |item|
      left, right = *item

      if NOTES[left]
        @notes << NOTES[left]
        left << "<span class=\"footnote\"><sup><a href=\"##{@footnote}\">#{@footnote}</a></sup></span>"
        @footnote += 1
      end

      if right.is_a? Array
        out << li(left + make_list(right, right.delete(["horizontal"])))
      else
        if NOTES[right]
          @notes << NOTES[right]
          footnote = "<span class=\"footnote\"><sup><a href=\"##{@footnote}\">#{@footnote}</a></sup></span>"
          @footnote += 1
        else
          footnote = ""
        end

        url = left
        if url[0, 9] == "estate://"
          url = url[9..-1]
          domain = ""
        else
          domain = span("domain", "(" + domain_from_url(url) + ")")
        end

        domain = "" if quiet

        if horizontal
          out << a(right, url) + " " + domain
        else
          out << li(a(right, url) + footnote + " " + domain)
        end
      end
    end

    if !horizontal
     out << "</ul>"
    end

    out
  end

  def domain_from_url(url)
    url = url.dup

    url.gsub!(/https?:\/\/www\./, "")
    url.gsub!(/https?:\/\//, "")

    url.split("/")[0]
  end

  attr_reader :notes
end

#
# get input and output dirs
#

if Dir[dir_in].empty?
  puts "Input directory '#{dir_in}' doesn\'t exist."
  exit
end

if Dir[dir_in + "/config.rb"].empty?
  puts "Couldn't find '#{ dir_in }/config.rb"
  exit
end

if Dir[dir_in + "/index.rb"].empty?
  puts "Couldn't find '#{ dir_in }/index.rb"
  exit
end

#
# just copy all the files to the output directory
#

unless index_only
  FileUtils::rm_r(dir_out, :force => true)
  FileUtils::cp_r(dir_in, dir_out)
end

#
# load some input files
#

require(dir_in + "/config.rb")
require(dir_in + "/index.rb")

if Dir[dir_in + "/header.html"].empty?
  header = ''
else
  header = File.read(dir_in + "/header.html")
end

if Dir[dir_in + "/footer.html"].empty?
  footer = ''
else
  footer = File.read(dir_in + "/footer.html")
end

#
# build index.html
#

File.open(dir_out + "/index.html", "w") do |f|
  # headers
  f << interpolate_header(header, TITLE, "")
  f << INDEX_HEADER

  # title and description
  f << h1(TITLE)
  f << p(DESCRIPTION)

  # jump to
  section_links = LIST.collect do |section|
    name = section.first
    a(name, "#" + name.tr(" ", "_"))
  end
  f << p_id("jump", "Jump to: " + section_links.join(NBSP * 3)) unless section_links.empty?

  # the list
  estate = Estate.new
  LIST.each do |section|
    name, list = *section

    f << h3_id(name.tr(" ", "_"), name)

    desc = list.assoc('desc')
    if desc
      f << p(desc[1])
      list.delete(desc)
    end

    quiet = list.delete(['quiet'])

    f << estate.make_list(list, false, quiet)
  end

  # notes
  unless estate.notes.empty?
    f << h3("Notes")

    estate.notes.each_index do |note|
      f << "<p style=\"font-size: 10pt;\">"
      f << "<span id=\"#{note + 1}\" class=\"footnote\"><sup>#{note + 1}</sup></span> "
      f << estate.notes[note]
      f << "</p>"
    end
  end

  # footers
  f << INDEX_FOOTER
  f << footer
end

#
# convert .src.html files to .html files with headers and footers
#

unless index_only
  Dir[dir_out + "/*/*.src.html"].each do |filename|
    outfile = filename.gsub(/\.src\.html$/, ".html")
    file_title = File.read(filename).match(/<h1>(.+?)<\/h1>/)[1]

    File.open(outfile, "w") do |f|
      f << interpolate_header(header, TITLE + " - " + file_title, "../")
      f << "<p>back to <a href=\"../index.html\">#{TITLE}</a></p><hr />"
      f << File.read(filename)
      f << footer
    end
  end
end

#
# remove config files from output directory
#

unless index_only
  to_delete = ["config.rb", "index.rb", "header.html", "footer.html"]
  to_delete.collect! { |filename| dir_out + "/" + filename }
  FileUtils::rm(to_delete, :force => true)
  FileUtils::rm(Dir[dir_out + "/*/*.src.html"])
end

