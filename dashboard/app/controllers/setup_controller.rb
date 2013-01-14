
class SetupController < ApplicationController

  require 'rubygems'
  require 'git'

  #this guy knows that our dashboard.json file default lives in a certain directory
  DASHBOARD_JSON_FILE = 'public/dashboard.json'
  DASHBOARD_TEMPLATE = 'public/template.html'

  def self.parse_dashboard_definition(structure, widget_list)
    structure.each do | entry |
      if(entry.is_a?(Hash))
        handle_git_download(entry, widget_list)
      else

        dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
        dashboard_template.puts ' <div class="row">'
        dashboard_template.close

        SetupController::parse_dashboard_definition(entry, widget_list)

        dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
        dashboard_template.puts ' </div>'
        dashboard_template.close

      end
    end

  end

  def self.handle_git_download(entry, widget_list)
    puts "\n handle git: " + entry.inspect
    git_url = entry["source"]
    css_span = entry["span"]
    puts "url: " + git_url
    git_url_bits = git_url.split('/')
    widget_type = git_url_bits[git_url_bits.size - 1]

    if !File.exists?('public/' + widget_type)
      Git.clone(git_url, 'public/' + widget_type)
    end

    widget_id = (Time.new.to_f * 1000000).to_i.to_s

    widget_config_file = 'public/config/widget_' + widget_id
    puts "wcf: " + widget_config_file
    widget_config = File.open(widget_config_file, 'w+')

    dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
    dashboard_template.puts '   <div id="' + widget_id.to_s + '" class="span' + css_span.to_s + ' widget">my widget: ' + widget_id.to_s
    dashboard_template.puts '      <script src="/' + widget_type + '/widget.js" type="text/javascript" ></script>'
    dashboard_template.puts '   </div>'
    dashboard_template.close

    widget_list << widget_id

  end

  def start
    file = File.open(DASHBOARD_JSON_FILE)
    puts "got a file! " + file.inspect

    widget_list = []

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
    dashboard_template.puts '<link href="/assets/dashboard.css" rel="stylesheet" type="text/css" />'
    dashboard_template.puts '<script src="/assets/jquery.js" type="text/javascript" ></script>'
    dashboard_template.puts '<div class="container">'
    dashboard_template.puts '<h1>Dashboard</h1>'
    dashboard_template.close

    puts "def: " + dashboard_definition.inspect
    SetupController::parse_dashboard_definition(dashboard_definition, widget_list)

    dashboard_template = File.open(DASHBOARD_TEMPLATE, 'a+')
    dashboard_template.puts '</div>'
    dashboard_template.puts '<script type="text/javascript">'
    dashboard_template.puts '    var widget_ids = ' + widget_list.inspect
    dashboard_template.puts '    for(var i = 0; i< widget_ids.length; i++){'
    dashboard_template.puts '       widgets[i].init(widget_ids[i]);'
    dashboard_template.puts '       console.log("init!!!");'
    dashboard_template.puts '    };'
    dashboard_template.puts '</script>'
    dashboard_template.close

    #redirect :controller => view, :action => dashboard
    puts "\n\n WIDGET LIST: " + widget_list.inspect
  end

  def save_config
      params.delete("action")
      params.delete("controller")
      widget_id = params[:widget_id]
      config_file = 'public/config/widget_' + widget_id
      if(File.exists?(config_file))
        config_file = File.open(config_file, "w")
        config_file.puts params.to_json
      end
      redirect_to :controller => "view", :action => "dashboard"
  end

end










