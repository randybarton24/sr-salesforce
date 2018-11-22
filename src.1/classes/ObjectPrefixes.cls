/**
 * File:        ObjectPrefixes.cls
 * Project:     Sererra 
 * Date:        January 8, 2013
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Collection of methods to get any object's name or label based on the object prefix
 * *************************************************************************
 * History:
 */
public class ObjectPrefixes 
{
    public Map<String,String> prefixObjectNameMap = new Map<String,String>{};
    public Map<String,String> objectNamePrefixMap = new Map<String,String>{};
    public Map<String,String> prefixObjectLabelMap = new Map<String,String>{};
    
    public ObjectPrefixes ()
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet)
        {
           Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
           String tempName = r.getName();
           String tempLabel = r.getLabel();
           String tempPrefix = r.getKeyPrefix();
           objectNamePrefixMap.put(tempName, tempPrefix); //object name, prefix
           prefixObjectNameMap.put(tempPrefix, tempName); //prefix, object name
           prefixObjectLabelMap.put(tempPrefix, tempLabel); //prefix, object label
        }
    }
    
    public String getPrefixByObjectName(String objectName) 
    {
        return objectNamePrefixMap.get(objectName);
    }
    
    public String getObjectNameByPrefix(String prefix) 
    {
        return prefixObjectNameMap.get(prefix);
    }
    
    public String getObjectLabelByPrefix(String prefix) 
    {
        return prefixObjectLabelMap.get(prefix);
    }
}