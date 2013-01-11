class ViewController < ApplicationController

  def dashboard

    render Rails.root.join('public/template.html').to_s
  end

end
