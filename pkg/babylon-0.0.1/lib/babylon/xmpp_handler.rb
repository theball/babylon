module Babylon
  require 'eventmachine'
  require 'nokogiri'  # used for SaxParsing  

  # This class is in charge of handling the network connection to the XMPP server.
  class NotConnected < Exception; end

  class XmppHandler < EventMachine::Connection

    def reconnect host = @host, port = @port
      super
    end

    def unbind()
      EventMachine::stop_event_loop
    end

    def initialize(config)
      super
      @host = config["host"]
      @port = config["port"]
      @debug = config["debug"]
      @dispatcher = config[:dispatcher]
      document = Babylon::XmppStream.new(@dispatcher)
      @parser = Nokogiri::XML::SAX::Parser.new(document)
    end

    def connection_completed
      super
      send_data("<?xml version='1.0' ?>")
      @dispatcher.start_streaming(self)
    end

    def send_data(data)
      puts " >> #{data}" if @debug # Very low level Logging
      super "#{data}"
    end

    def receive_data(data)
      puts " << #{data}"  if @debug # Very low level Logging
      @parser.parse "#{data}"
    end
  end

  class XmppStream < Nokogiri::XML::SAX::Document
    def initialize(dispatcher)
      @dispatcher = dispatcher
      @elem = nil
      @started = false
      super()
    end  

    def characters(string)
      @elem.add(REXML::Text.new(string)) if @elem
    end

    def cdata_block(string)
    end

    def start_element(name, attributes = [])
      e = REXML::Element.new(name)
      # Attributes is an array like [name, value, name, value]...
      (attributes.size()/2).times do |i|
         if attributes[2*i] == 'xmlns'
           e.add_namespace attributes[2*i+1]
         else
           e.attributes[attributes[2*i]] = attributes[2*i+1]
         end
      end
      
      @elem = @elem ? @elem.add(e) : e

      if @elem.name == 'stream' and not @started
        @started = true
        # stream is different! We must callback now ;)
        @dispatcher.dispatch(@elem)
        @elem = nil
      end
    end

    def end_element(name)
      if @elem
        @dispatcher.dispatch(@elem) unless @elem.parent
        @elem = @elem.parent
      end
    end
  end

end