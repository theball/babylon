# Routes require an xpath against which to match, and a controller/action pair to which to map.
#
# xpath("//message[@type = 'chat']"
# ).to(:controller => "message", :action => "receive")
#
# Routes can be assigned priorities. The highest priority executes first, and the default priority is 0.
#
# xpath("//message[@type = 'chat']"
# ).to(:controller => "message", :action => "priority"
# ).priority(5000000)
#
# It is not possible to easily check for namespace URI equivalence in xpath, but the following helper function was added.
#
# xpath("//iq[@type='get']/*[namespace(., 'query', 'http://jabber.org/protocol/disco#info')]"
# ).to(:controller => "discovery", :action => "services")
#
# That syntax is ugly out of necessity. But, relax, you're using Ruby.
#
# There are a few helper methods for generating xpaths. The following is equivalent to the above example:
#
# disco_info.to(:controller => "discovery", :action => "services")
#
# See lib/babylon/router/dsl.rb for more helpers.

