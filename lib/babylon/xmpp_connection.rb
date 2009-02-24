module Babylon
  require 'eventmachine'
  require 'nokogiri'

  # This class is in charge of handling the network connection to the XMPP server.
  class NotConnected < Exception; end

  class XmppConnection < EventMachine::Connection

    def self.connect(config)
      EventMachine::connect config['host'], config['port'], self, config
    end

    def reconnect host = @host, port = @port
      super
    end

    def unbind()
      EventMachine::stop_event_loop
    end

    def initialize(config)
      @config = config
      super()
      @parser = XmppParser.new(&method(:receive_stanza))
    end

    def receive_stanza(stanza)
      # If not handled by subclass (for authentication)
      CentralRouter.route self, stanza
    end

    def connection_completed
      super
      builder = Nokogiri::XML::Builder.new {
        self.send('stream:stream', :xmlns => "jabber:component:accept", 'xmlns:stream' => 'http://etherx.jabber.org/streams', :to => "pubsubapi-dev.xmpp.notifixio.us") {
          paste_content_here() # This the stream should be cut here ;)
        }
      }
      @start_stream, @stop_stream = builder.to_xml.split('<paste_content_here/>')
      send_data(@start_stream)
    end

    def send(xml)
      send_data xml.to_s
    end

    def send_data(data)
      puts " >> #{data}" if debug? # Very low level Logging
      super
    end

    def receive_data(data)
      puts " << #{data}"  if debug? # Very low level Logging
      @parser.parse data
    end

    def debug?
      @config["debug"]
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
      # If this is the stream:stream element, get the namespace and add them to the doc!
      # if qname == "stream:stream"
        
        # add_namespaces_and_attributes_to_node(attributes, )
      # else
      e = Nokogiri::XML::Element.new(qname, @doc)
      add_namespaces_and_attributes_to_node(attributes, e)
      # end
      
      @elem = @elem ? @elem.add_child(e) : (@root = e)
      if @elem.parent.nil?
        # Should be called only for stream:stream
        @doc.root = @elem
        @callback.call(@elem)
      end
    end

    def end_element(name)
      if @elem
        @callback.call(@elem) if @elem.parent == @root
        @elem = @elem.parent
        # now remove from parent again to avoid space leak:
        # TODO
      end
    end
    
    private
    
    def add_namespaces_and_attributes_to_node(attrs, node) 
      # Attributes is an array like [name, value, name, value]...
      (attrs.size / 2).times do |i|
        name, value = attrs[2 * i], attrs[2 * i + 1]
        if name =~ /xmlns/
          node.add_namespace(name, value)
        else
          node.set_attribute name, value
        end
      end
    end
    
  end

end
