
class SetupController < ApplicationController

  require 'rubygems'
  require 'git'

  #this guy knows that our dashboard.json file default lives in a certain directory
  DASHBOARD_JSON_FILE = 'public/dashboard.json'
  DASHBOARD_TEMPLATE = 'public/template.html'

  def self.parse_dashboard_definition(structure)
    structure.each do | entry |
      if(entry.is_a?(Hash))
        handle_git_download(entry)
      else

        dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
        dashboard_template.puts ' <div class="row">'
        dashboard_template.close

        SetupController::parse_dashboard_definition(entry)

        dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
        dashboard_template.puts ' </div>'
        dashboard_template.close

      end
    end

  end

  def self.handle_git_download(entry)
    puts "\n handle git: " + entry.inspect
    git_url = entry["source"]
    css_span = entry["span"]
    puts "url: " + git_url
    git_url_bits = git_url.split('/')
    widget_type = git_url_bits[git_url_bits.size - 1]

    if !File.exists?('public/' + widget_type)
      Git.clone(git_url, 'public/' + widget_type)
    end

    widget_timestamp = (Time.new.to_f * 1000000).to_i.to_s

    widget_config_file = 'public/config/widget_' + widget_timestamp
    puts "wcf: " + widget_config_file
    widget_config = File.open(widget_config_file, 'w+')

    dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
    dashboard_template.puts '   <div class=span' + css_span.to_s + '>my widget: ' + widget_timestamp.to_s

    dashboard_template.puts '      <script src="/' + widget_type + '/widget.js" type="text/javascript" ></script>'

    dashboard_template.puts '   </div>'

    dashboard_template.close

  end

  def start
    file = File.open(DASHBOARD_JSON_FILE)
    puts "got a file! " + file.inspect

    dashboard_json = file.read

    dashboard_definition = ActiveSupport::JSON.decode(dashboard_json)

    dashboard_definition.each do | entry |
      puts "-" + entry.inspect
    end

    dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
    dashboard_template.puts '<script type="text/javascript">'
    dashboard_template.puts '    var widgets = []; '
    dashboard_template.puts '</script>'

    dashboard_template.puts '<link href="/assets/bootstrap.css" rel="stylesheet" type="text/css" />'
    dashboard_template.puts '<div id="testing"></div>'
    dashboard_template.puts '<div class="container">'
    dashboard_template.close

    puts "def: " + dashboard_definition.inspect
    SetupController::parse_dashboard_definition(dashboard_definition)

    dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
    dashboard_template.puts '</div>'
    dashboard_template.close

    #redirect :controller => view, :action => dashboard
  end

end
