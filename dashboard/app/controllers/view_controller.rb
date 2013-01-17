class ViewController < ApplicationController

  def dashboard

    render Rails.root.join('public/template.html').to_s
  end

  def get_oauth_github_data

    github_url = params[:github_url]
    puts "\n\n got this url: " + github_url

    render :json => ["OK", "lala"]
  end

  def authorise_with_github
    redirect_to GithubOAuth.authorize_url('9c061bb2d1730b4e00e0', 'd670120bfc5088699cd2eda54a8dc59247a9afff')

  end

  def authorize
    @code = params[:code]
    puts "\n\n GOT githut access code!" + @code
  end

  def get_access_token

    @code = params[:code]
    puts "\n\n got this code: " + @code
    @access_token = GithubOAuth.token('9c061bb2d1730b4e00e0', 'd670120bfc5088699cd2eda54a8dc59247a9afff', @code)

  end


end
