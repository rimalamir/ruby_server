require 'socket'
require 'erb'
require 'ostruct'

class RequestParser
  @@coubt = 0
  def parse(request)
    method, path, version = request.lines[0].split
    @@coubt += 1
    p @@coubt
    p "Times"
    {
      path: path,
      method: method,
      headers: parse_headers(request)
    }
  end

  def parse_headers(request)
    headers = {}

    request.lines[1..-1].each do |line|
      return headers if line == "\r\n"

      header, value = line.split
      header        = normalize(header)

      headers[header] = value
    end
  end

  def normalize(header)
    header.gsub(":", "").downcase.to_sym
  end
end

class Response
  attr_reader :code

  def initialize(code:, data: "")
    @response =
      "HTTP/1.1 #{code}\r\n" +
        "Content-Length: #{data.size}\r\n" +
        "\r\n" +
        "#{data}\r\n"

    @code = code
  end

  def send(client)
    client.write(@response)
  end
end

class ResponseBuilder
  SERVER_ROOT = "/Users/rimalamir/Documents/Learn/Ruby/server_on_ruby/"

  def prepare(request)
    @name = "AMIR SIR"
    @code = "GOOD MAN"
    @desc = "I know it"
    @features = ["Honest", "Reliable"]
    @cost = 5

    template = File.open("index.html.erb").read
    template_rendering = ERB.new(template)


    Response.new(code: 200, data: template_rendering.result(binding))
  end
end

server  = TCPServer.new('localhost', 8080)

loop {
  client  = server.accept
  request = client.readpartial(2048)

  request  = RequestParser.new.parse(request)
  response = ResponseBuilder.new.prepare(request)

  response.send(client)
  client.close
}


