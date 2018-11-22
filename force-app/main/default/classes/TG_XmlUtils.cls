global class TG_XmlUtils
{
/**
Class that encapsulates info about a Node's localName and its NameSpaceURI
*/
    public class NodeNameInfo
    {
        public String localName {get;set;}
        public String namespaceURI {get;set;}
        public String nameSpacePrefix {get;set;}

        public NodeNameInfo(String lName, String nsURI, String nsPrefix) 
        {
            this.localName = lName;
            this.namespaceURI = nsURI;
            this.nameSpacePrefix = nsPrefix;
        }
    }
    public static NodeNameInfo getNamespaceFromNodeName(String nodeName, Dom.XmlNode baseNode) 
    {
        String nameSpace = null;
        String nameSpacePrefix = null;
        Integer colonIdx = nodeName.indexOf(':');
        if (colonIdx > 0 ) 
        {
            nameSpacePrefix = nodeName.substring(0, colonIdx);
            nodeName = nodeName.substring(colonIdx + 1);
            nameSpace = baseNode.getNamespaceFor(nameSpacePrefix);
        }
        return new NodeNameInfo(nodeName, nameSpace, nameSpacePrefix);
    }

    public static String toXmlString(Dom.XmlNode xmlNode) 
    {
        String ns = xmlNode.getNamespace();
        String prefix = ns == null ? '' : xmlNode.getPrefixFor(ns);
        prefix = prefix == '' || prefix == null ? '' : prefix + ':';
        String xmlrep = '<' + prefix + xmlNode.getName() ;
        Integer attribCount = xmlNode.getAttributeCount();
        for (Integer idx = 0 ; idx < attribCount ; idx ++) 
        {
            String aNs = xmlNode.getAttributeKeyNsAt(idx);
            String aKey = xmlNode.getAttributeKeyAt(idx);
            String aVal = xmlNode.getAttributeValue(aKey, aNs);
            String aPrefix = '';
            aPrefix = aNs == null ? '' : xmlNode.getPrefixFor(aNs);
            aPrefix = aPrefix == '' || aPrefix == null ? '' : aPrefix + ':';
            xmlrep += ' ' +aPrefix + aKey + '=\'' + aVal + '\'' ;
        }
        xmlrep += '>';

        Dom.XmlNode [] children = xmlNode.getChildren();
        if (children != null && !children.isEmpty()) 
        {
            for (Dom.XmlNode child : children) 
            {
                if (child.getNodeType() == dom.XmlNodeType.TEXT) 
                {
                    xmlrep += child.getText();
                }
                else if (child.getNodeType() == dom.XmlNodeType.COMMENT)
                {
                    // do nothing !
                }
                else if (child.getNodeType() == dom.XmlNodeType.ELEMENT)
                {
                    xmlrep += toXmlString(child);
                }
            }
        }

        return xmlrep + '</' + prefix + xmlNode.getName() + '>';
    }

    public static void copyAttributes(Dom.XmlNode fromN, Dom.XmlNode toN)
    {
        Integer attribCount = fromN.getAttributeCount();
        for (Integer idx = 0 ; idx < attribCount ; idx ++) 
        {
            String aNs = fromN.getAttributeKeyNsAt(idx);
            String aKey = fromN.getAttributeKeyAt(idx);
            String aVal = fromN.getAttributeValue(aKey, aNs);
            String vNs = fromN.getAttributeValueNs(aKey, aNs);
            toN.setAttributeNs(aKey, aVal, aNs, vNs);
            String aPrefix = aNs != null ? fromN.getPrefixFor(aNs) : null;
            String vPrefix = vNs != null ? fromN.getPrefixFor(vNs) : null;
            if (aPrefix != null)toN.setNamespace(aPrefix, aNs);
            if (vPrefix != null)toN.setNamespace(vPrefix, vNs);
        }
    }

    global static Dom.XmlNode appendChild (Dom.XmlNode inNode, Dom.XmlNode nodeToAppend)
    {
        Dom.XmlNode addedNode = null;
        // Elements can only be added to ELEMENT Nodes. Other 2 supported by Spring 10 Apex XML DOM API
        // are COMMENT and TEXT that can't have child nodes
        // We are intentionally leaving the error handling upto Spring 10 API, I checked
        // on such situations Xml DOM API throw System.Xmlexception
        String nsURI = nodeToAppend.getNamespace();
        String nsPrefix = nsURI != null ? nodeToAppend.getPrefixFor(nsURI) : null;
        addedNode = inNode.addChildElement(nodeToAppend.getName(), nsURI, nsPrefix);

        // Copy attributes from the original node to the appended node.
        copyAttributes(nodeToAppend, addedNode);
        // copy the kids from the original to the appended node.
        copyKids(nodeToAppend, addedNode);
        return addedNode;
    }

    public static Dom.XmlNode clone(Dom.XmlNode xmlNode, boolean deep)
    {
        String nsURI = xmlNode.getNamespace();
        String nsPrefix = nsURI != null ? xmlNode.getPrefixFor(nsURI) : null;
        Dom.Document domc = new Dom.Document();
        Dom.XmlNode cloned = domc.createRootElement(xmlNode.getName(), nsURI, nsPrefix);

        // Copy the node attributes
        copyAttributes(xmlNode, cloned);
        // if deep clone, copy the kids too.
        if (deep) copyKids(xmlNode, cloned);

        return cloned;
    }

    public static void copyKids(Dom.xmlnode fromNode, Dom.xmlnode toNode)
    {
        Dom.XmlNode [] children = fromNode.getChildren();
        if (children != null && !children.isEmpty())
        {
            for (Dom.XmlNode child : children)
            {
                String kidName = child.getName();
                String kidNSURI = child.getNamespace();
                String kidPrefix = kidNSURI != null ? child.getPrefixFor(kidNSURI) : null;

                if (child.getNodeType() == dom.XmlNodeType.TEXT) 
                {
                    toNode.addTextNode(child.getText());
                }
                else if (child.getNodeType() == dom.XmlNodeType.COMMENT) 
                {
                    toNode.addCommentNode(child.getText());
                }
                else if (child.getNodeType() == dom.XmlNodeType.ELEMENT) 
                {
                    Dom.XmlNode copiedChild = toNode.addChildElement(kidName, kidNSURI, kidPrefix);
                    copyAttributes(child, copiedChild);
                    copyKids(child, copiedChild);
                }
            }
        }

    }

    public static String getTextContents(Dom.XmlNode node) 
    {
        String textRep = '';
        Dom.XmlNode [] children = node.getChildren();
        if (children != null && !children.isEmpty())
        {
            for (Dom.XmlNode child : children)
            {
                if (child.getNodeType() == dom.XmlNodeType.TEXT)
                {
                    textRep += ' ' + child.getText();
                } 
                else if (child.getNodeType() == dom.XmlNodeType.ELEMENT)
                {
                    textRep += ' ' + getTextContents(child);
                }
            }
        }
        return textRep.trim() ;
    }
}