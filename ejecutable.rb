require 'rack'
require 'thin'
require 'halm'
  
  module PiedraPapelTijera
    class App 
  
      def initialize(app = nil)
        @app = app
        @content_type = :html
        @defeat = {'piedra' => 'tijeras', 'papel' => 'piedra', 'tijera' => 'papel'}
        @throws = @defeat.keys
        @choose = @throws.map { |x| 
           %Q{ <li><a href="/?choice=#{x}">#{x}</a></li> }
        }.join("\n")
        @choose = "<p>\n<ul>\n#{@choose}\n</ul>"
      end
  
      def call(env)
        req = Rack::Request.new(env)
  
        req.env.keys.sort.each { |x| puts "#{x} => #{req.env[x]}" }
  
        computer_throw = @throws.sample
        player_throw = req.GET["choice"]
        answer = if !@throws.include?(player_throw)
            "Elija una de las siguientes:"
          elsif player_throw == computer_throw
            "Empataste con la máquina"
          elsif computer_throw == @defeat[player_throw]
            "Felicidades, ganaste; #{player_throw} gana #{computer_throw}"
          else
            "Lástima; #{computer_throw} gana #{player_throw}. Suerte la próxima vez"
          end
  
        res = Rack::Response.new
        res.write <<-"EOS"
        <html>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
          <title>PiedraPapelTijera</title>
          <body>
            <h1>
               #{answer}
               #{@choose}
            </h1>
          </body>
        </html>
        EOS
        res.finish
      end # call
    end   # App
  end     # PiedraPapelTijera
  
  if $0 == __FILE__
    Rack::Server.start(
      :app => Rack::ShowExceptions.new(
                Rack::Lint.new(
                  PiedraPapelTijera::App.new)), 
      :Port => 8080,
      :server => 'thin'
    )
  end
