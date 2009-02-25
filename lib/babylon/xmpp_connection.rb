module Babylon

  ## 
  # Connection Exception
  class NotConnected < Exception; end

  ##
  # This class is in charge of handling the network connection to the XMPP server.
  class XmppConnection < EventMachine::Connection

    ##
    # Connects the XmppConnection to the right host with the right port. 
    # It passes itself (as handler) and the configuration
    def self.connect(config)
      EventMachine::connect config['host'], config['port'], self, config
    end

    ##
    # Called when the connection is terminated and stops the event loop
    def unbind()
      EventMachine::stop_event_loop
    end

    ## 
    # Instantiate the Handler (called internally by EventMachine) and attaches a new XmppParser
    def initialize(config)
      @config = config
      super()
      @parser = XmppParser.new(&method(:receive_stanza))
    end

    ##
    # Called when a full stanza has been received and returns it to the central router to be sent to the corresponding controller.
    def receive_stanza(stanza)
      # If not handled by subclass (for authentication)
      CentralRouter.route self, stanza
    end

    ##
    # Connection_completed is called when the connection (socket) has been established and is in charge of "building" the XML stream to establish the XMPP connection itself 
    # We use a "tweak" here to send only the starting tag of stream:stream
    def connection_completed
      super
      builder = Nokogiri::XML::Builder.new {
        self.send('stream:stream', 'xmlns' => "jabber:component:accept", 'xmlns:stream' => 'http://etherx.jabber.org/streams', 'to' => "pubsubapi-dev.xmpp.notifixio.us") {
          paste_content_here() # This the stream should be cut here ;)
        }
      }
      @start_stream, @stop_stream = builder.to_xml.split('<paste_content_here/>')
      send_data(@start_stream)
    end
    
    ## 
    # Sends data (string) on the stream
    def send(xml)
      send_data xml.to_s
    end

    private

    ## 
    # Send_data sends the data, but eventually displays the debug information as well
    def send_data(data)
      puts " >> #{data}" if debug? # Very low level Logging
      super
    end


    ## 
    # receive_data is called when data is received. It is then passed to the parser. Eventually it displays this data for debugging purposes
    def receive_data(data)
      puts " << #{data}"  if debug? # Very low level Logging
      @parser.parse data
    end
    
    ## 
    # Pretty self-explanatory ;)
    def debug?
      @config["debug"]
    end
  end

  ##
  # This is the XML SAX Parser that accepts "pushed" content
  class XmppParser #< Nokogiri::XML::SAX::Document
    
    ##
    # Initialize the parser and adds the callback that will be called upen stanza completion
    def initialize(&callback)
      @callback = callback
      super()
      @parser = Nokogiri::XML::SAX::Parser.new(self)
      @doc = nil
      @elem = nil
    end
    
    ##
    # Parses the received data
    def parse(data)
      @parser.parse data
    end

    ## 
    # Called when the document received in the stream is started
    def start_document
      @doc = Nokogiri::XML::Document.new
    end

    ##
    # Adds characters to the current element (being parsed)
    def characters(string)
      @elem.add(Nokogiri::XML::Text.new(string, @doc)) if @elem
    end
    alias :characters :cdata_block

    ##
    # Instantiate a new current Element, adds the corresponding attributes and namespaces
    # The new element is eventually added to a parent element (if present).
    # If this element is the first element (the root of the document), then instead of adding it to a parent, we add it to the document itself. In this case, the current element will not be terminated, so we activate the callback immediately.
    def start_element(qname, attributes = [])
      # If this is the stream:stream element, get the namespace and add them to the doc!
      e = Nokogiri::XML::Element.new(qname, @doc)
      add_namespaces_and_attributes_to_node(attributes, e)
      
      @elem = @elem ? @elem.add_child(e) : (@root = e)
      if @elem.parent.nil?
        # Should be called only for stream:stream
        @doc.root = @elem
        @callback.call(@elem)
      end
    end

    ##
    # Terminates the current element and calls the callback
    def end_element(name)
      if @elem
        @callback.call(@elem) if @elem.parent == @root
        @elem = @elem.parent
      end
    end
    
    private
    
    ##
    # Adds namespaces and attributes. Nokogiri passes them as a array of [name, value, name, value]...
    def add_namespaces_and_attributes_to_node(attrs, node) 
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
