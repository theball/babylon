module Babylon
  require 'eventmachine'
  require 'nokogiri'  # used for SaxParsing  

  # This class is in charge of handling the network connection to the XMPP server.
  class NotConnected < Exception; end

  class XmppConnection < EventMachine::Connection

    def self.connect(config)
      Logger.info " -- Connecting to #{config['host']},#{config['port']} as #{self}"
      EventMachine::connect config['host'], config['port'], self, config
    end

    def reconnect host = @host, port = @port
      super
    end

    def unbind()
      Logger.warn " -- unbind (error=#{error?})"
      EventMachine::stop_event_loop
    end

    def initialize(config)
      @config = config
      super()
    end

    def receive_stanza(stanza)
      # If not handled by subclass (for authentication)
      CentralRouter.route self, stanza
    end

    def connection_completed
      super
      restart_stream
    end

    def restart_stream
      send_xml("<?xml version='1.0'?>")

      # And now, that we're connected, we must send a <stream>
=begin
      stream = REXML::Element.new("stream:stream")
      stream.add_namespace(stream_namespace)
      stream.add_attribute('xmlns:stream', 'http://etherx.jabber.org/streams')
      stream.add_attribute('to', stream_to)
      stream.add_attribute('version', "1.0")
      stream.add(REXML::Element.new('CUT-HERE'))
=end
      namespace, to = stream_namespace, stream_to
      stream = Ramaze::Gestalt.build {
        send(:'stream:stream',
             :xmlns => namespace,
             :'xmlns:stream' => 'http://etherx.jabber.org/streams',
             :to => to,
             :version => '1.0') { send :CUT_HERE }
      }
      @start_stream, @stop_stream = stream.to_s.split(/<CUT_HERE.*?\/>/)
      send_xml(@start_stream)

      @parser = XmppParser.new(&method(:receive_stanza))
    end

    def send_xml(xml)
      send_data xml.to_s
    end

    def send_data(data)
      Logger.debug " >> #{data}"
      super
    end

    def receive_data(data)
      Logger.debug " << #{data}"
      @parser.parse data
    end
  end

  class XmppParser < Nokogiri::XML::SAX::Document
    def initialize(&callback)
      @callback = callback
      super()
      @parser = Nokogiri::XML::SAX::Parser.new(self)
      @doc = nil
      @elem = nil
    end  

    def parse(data)
      @parser.parse data
    end

    def start_document
      @doc = Nokogiri::XML::Document.new
    end

    def characters(string)
      @elem.add(Nokogiri::XML::Text.new(string, @doc)) if @elem
    end
    alias :characters :cdata_block

    def start_element(qname, attributes = [])
      e = Nokogiri::XML::Element.new(qname, @doc)
      # Attributes is an array like [name, value, name, value]...
      (attributes.size / 2).times do |i|
        name, value = attributes[2 * i], attributes[2 * i + 1]
        e.set_attribute name, value
      end
      
      @elem = @elem ? @elem.add_child(e) : (@root = e)
      if @elem.parent.nil?
        @callback.call(@elem)
      end
    end

    def end_element(name)
      if @elem
        p :close => @elem.to_s, :parent => @elem.parent, :x => @doc.xpath('*', 'stream' => 'http://etherx.jabber.org/streams').to_ary, :path => @elem.path
        @callback.call(@elem) if @elem.parent == @root
        @elem = @elem.parent
        # now remove from parent again to avoid space leak:
        # TODO
      end
    end
  end

end
