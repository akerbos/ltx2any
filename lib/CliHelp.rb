# Copyright 2010-2016, Raphael Reitzig
# <code@verrech.net>
#
# This file is part of ltx2any.
#
# ltx2any is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ltx2any is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ltx2any. If not, see <http://www.gnu.org/licenses/>.

require 'singleton'

class CliHelp
  include Singleton

  def initialize
    @hashes = {}
  end

  public

  def provideHelp(args)
    params = ParameterManager.instance
    
    # Check for help/usage commands
    if ( args.length == 0 || /--help|--h/ =~ args[0] )
      puts "\nUsage: "
      puts "  #{NAME} [options] inputfile\tNormal execution (see below)"
      puts "  #{NAME} --extensions\t\tList of extensions"
      puts "  #{NAME} --engines\t\tList of target engines"
      puts "  #{NAME} --dependencies\t\tList of dependencies"
      puts "  #{NAME} --version\t\tPrints version information"
      puts "  #{NAME} --help\t\tThis message"

      puts "\nOptions:"
      #params.keys.sort.each { |key|
      #  puts "  -#{key}\t#{if ( params[key][0] != nil ) then codes[key][0] end}\t#{params[key]}"
      #}
      params.user_info.each { |a|
        puts "  -#{a[:code]}\t#{a[:help]}"
      }

      # TODO output unsatisfied dependencies

      return true
    elsif ( args[0] == "--extensions" )
      puts "Installed extensions in execution order:"
      maxwidth = Extension.list.map { |e| e.name.length }.max
      Extension.list.each { |e|
        puts "  #{e.name}#{" " * (maxwidth - e.name.length)}\t#{e.description}"
      }
      return true
    elsif ( args[0] == "--engines" )
      puts "Installed engines:"
      Engine.list.each { |e|
        if DependencyManager.list(source: [:engine, e.binary], relevance: :essential).all? { |d| d.available? }
          print "  #{e.name}\t#{e.description}"
          if ( e.to_sym == params[:engine] )
            print " (default)"
          end
          puts ""
        end
      }
      return true
    elsif ( args[0] == "--dependencies" )
      puts DependencyManager.to_s # TODO make prettier?
      return true
    elsif ( args[0] == "--version" )
      puts "#{NAME} #{VERSION}"
      puts "Copyright \u00A9 #{AUTHOR} #{YEAR}".encode('utf-8')
      puts "This is free software; see the source for copying conditions."
      puts "There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
      return true
    else # No help requested
      return false
    end
  end

end