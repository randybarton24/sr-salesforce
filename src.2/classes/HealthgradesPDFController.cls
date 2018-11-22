public without sharing class HealthgradesPDFController extends WebFormsUtilityClass {
    
    public String oppId { get; set; }
    public String contractDateTime { get; set; }
    public String contractSignedIP { get; set; }
    public String contractSigner { get; set; }
    public String contractTerm { get; set; }
    public String contractFreeMonths { get; set; }
    public String contractDate { get; set; }
    public String salesRep { get; set; }
    public String businessName { get; set; }
    public String addressStreet { get; set; }
    public String addressCity { get; set; }
    public String addressState { get; set; }
    public String addressPostalCode { get; set; }
    public String addressCountry { get; set; }
    public String providerName { get; set; }
    public String providerEmail { get; set; }
    public String providerPhone { get; set; }
    public String providerNPI { get; set; }
    public String providerURL { get; set; }
    public Opportunity relatedOpportunity { get; set; }
    public OpportunityLineItem[] relatedOppLis { get; set; }

    /**
     * Constructor to initialize variables. Values are passed from the HealthgradesContractController.
     * @see HealthgradesContractController.generateContractPdf
     */
    public HealthgradesPDFController() {
        
        oppId = getURParameter('oppId') == null ? '' : getURParameter('oppId');
        contractDateTime = getURParameter('contractDateTime') == null ? '-' : getURParameter('contractDateTime');
        contractSignedIP = getURParameter('contractSignedIP') == null ? '-' : getURParameter('contractSignedIP');
        contractSigner = getURParameter('contractSigner') == null ? '-' : getURParameter('contractSigner');
        contractTerm = getURParameter('contractTerm') == null ? '24' : getURParameter('contractTerm');
        contractFreeMonths = getURParameter('contractFreeMonths') == null ? '24' : getURParameter('contractFreeMonths');
        contractDate = getURParameter('contractDate') == null ? '-' : getURParameter('contractDate');
        businessName = getURParameter('businessName') == null ? '-' : getURParameter('businessName');
        addressStreet = getURParameter('addressStreet') == null ? '-' : getURParameter('addressStreet');
        addressCity = getURParameter('addressCity') == null ? '-' : getURParameter('addressCity');
        addressState = getURParameter('addressState') == null ? '-' : getURParameter('addressState');
        addressPostalCode = getURParameter('addressPostalCode') == null ? '-' : getURParameter('addressPostalCode');
        addressCountry = getURParameter('addressCountry') == null ? '-' : getURParameter('addressCountry');
        providerName = getURParameter('providerName') == null ? '-' : getURParameter('providerName');
        providerEmail = getURParameter('providerEmail') == null ? '-' : getURParameter('providerEmail');
        providerPhone = getURParameter('providerPhone') == null ? '-' : getURParameter('providerPhone');
        providerNPI = getURParameter('providerNPI') == null ? '-' : getURParameter('providerNPI');
        providerURL = getURParameter('providerURL') == null ? '-' : getURParameter('providerURL');
        relatedOpportunity = retrieveOpportunityData(oppId);
        relatedOppLis = relatedOpportunity.OpportunityLineItems;
        salesRep = relatedOpportunity.Owner.Name;
    }
}