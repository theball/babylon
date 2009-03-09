module Babylon

  # Custom XPath functions for stanza-routing.
  class XpathHelper

    # Match nodes of the given name with the given namespace URI.
    def namespace(set, name, nsuri)
      set.find_all.each do |n|
        n.name == name && n.namespaces.values.include?(nsuri)
      end
    end
  end
end
