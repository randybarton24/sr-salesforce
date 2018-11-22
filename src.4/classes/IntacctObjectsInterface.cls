/**
 * File:        IntacctObjectsInterface.cls
 * Project:     Sererra 
 * Date:        December 20, 2012
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: The interface for all the Intacct objects
 * *************************************************************************
 * History:
 */
public virtual class IntacctObjectsInterface 
{
    public class IntacctObject 
    {
        public Object intacctObject;
        public Boolean isCreate = true;
        public Id salesforceId;
        public String objectType;
        public String intacctEntity = '';
        public String uniqueIdentifier;
        
        public IntacctObject(Object syncObject) 
        {
            this.intacctObject = syncObject;
            
            //contact object
            if(this.intacctObject instanceOf IntacctObjectContact) 
            { 
                objectType = 'contact';  
                intacctEntity = ((IntacctObjectContact)this.intacctObject).intacctEntity;
                salesforceId = ((IntacctObjectContact)this.intacctObject).salesforceId;
                uniqueIdentifier = ((IntacctObjectContact)this.intacctObject).uniqueIdentifier;
            }
            
            //customer object
            if(this.intacctObject instanceOf IntacctObjectCustomer) 
            { 
                objectType = 'customer';
                intacctEntity = ((IntacctObjectCustomer)this.intacctObject).intacctEntity;
                salesforceId = ((IntacctObjectCustomer)this.intacctObject).salesforceId; 
                uniqueIdentifier = ((IntacctObjectCustomer)this.intacctObject).uniqueIdentifier;
            }
        }
    }    
    public class Address 
    {
        public String address1;
        public String address2;
        public String city;
        public String state;
        public String zip;
        public String country;
        public String isoCountryCode;
    }

    public class IntacctDate 
    {
        public String year;
        public String month;
        public String day;
        
        public IntacctDate(Date value) 
        {
            if(value != null)
            {
                year = String.valueOf(value.year());
                month = String.valueOf(value.month());
                day = String.valueOf(value.day());
            }
        }
    }
    
    public class CustomField 
    {
        public String customFieldName;
        public String customFieldValue;
    }
    
    public class ExpiryDate 
    {
        public String expMonth;
        public String expYear;
        
        public ExpiryDate(Date value) 
        {
            expYear = String.valueOf(value.year());
            expMonth = String.valueOf(value.month());
        }
    }
    
    public class ExpressionFilter
    {
        public String fieldName;
        public String operator;
        public String value;
    }
}