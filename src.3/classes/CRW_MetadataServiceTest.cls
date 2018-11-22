/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * This is a dummy test class to obtain 100% coverage for the generated WSDL2Apex code, it is not a funcitonal test class
 **/
@isTest
private class CRW_MetadataServiceTest
{
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
	private class WebServiceMockImpl implements WebServiceMock
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType)
		{
			if(request instanceof CRW_MetadataService.retrieve_element)
				response.put('response_x', new CRW_MetadataService.retrieveResponse_element());
			else if(request instanceof CRW_MetadataService.listMetadata_element)
				response.put('response_x', new CRW_MetadataService.listMetadataResponse_element());
			else if(request instanceof CRW_MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new CRW_MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof CRW_MetadataService.describeMetadata_element)
				response.put('response_x', new CRW_MetadataService.describeMetadataResponse_element());
			else if(request instanceof CRW_MetadataService.deploy_element)
				response.put('response_x', new CRW_MetadataService.deployResponse_element());
            else if(request instanceof  CRW_MetadataService.upsertMetadata_element)
                response.put('response_x', new CRW_MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  CRW_MetadataService.createMetadata_element)
                response.put('response_x', new CRW_MetadataService.createMetadataResponse_element());
            else if(request instanceof CRW_MetadataService.describeValueType_element)
                response.put('response_x', new CRW_MetadataService.describeValueTypeResponse_element());
            else if(request instanceof CRW_MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new CRW_MetadataService.checkRetrieveStatusResponse_element());
			return;
		}
	}

	@IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        CRW_MetadataService metaDataService = new CRW_MetadataService();
        // Invoke operations
        CRW_MetadataService.MetadataPort metaDataPort = new CRW_MetadataService.MetadataPort();
	}

	@IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        CRW_MetadataService metaDataService = new CRW_MetadataService();
        // Invoke operations
        CRW_MetadataService.MetadataPort metaDataPort = new CRW_MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        CRW_MetadataService metaDataService = new CRW_MetadataService();
        // Invoke operations
        CRW_MetadataService.MetadataPort metaDataPort = new CRW_MetadataService.MetadataPort();
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
    }

	@IsTest
    private static void coverGeneratedCodeTypes()
    {
        // Reference types
        new CRW_MetadataService();
        new CRW_MetadataService.listMetadataResponse_element();
        new CRW_MetadataService.DescribeMetadataResult();
        new CRW_MetadataService.FilterItem();
        new CRW_MetadataService.LogInfo();
        new CRW_MetadataService.CallOptions_element();
        new CRW_MetadataService.describeMetadataResponse_element();
        new CRW_MetadataService.describeMetadata_element();
        new CRW_MetadataService.ProfileObjectPermissions();
        new CRW_MetadataService.RetrieveResult();
        new CRW_MetadataService.retrieve_element();
        new CRW_MetadataService.DescribeMetadataObject();
        new CRW_MetadataService.CustomField();
        new CRW_MetadataService.deployResponse_element();
        new CRW_MetadataService.FileProperties();
        new CRW_MetadataService.AsyncResult();
        new CRW_MetadataService.checkRetrieveStatus_element();
        new CRW_MetadataService.RetrieveRequest();
        new CRW_MetadataService.ListMetadataQuery();
        new CRW_MetadataService.DebuggingHeader_element();
        new CRW_MetadataService.Picklist();
        new CRW_MetadataService.listMetadata_element();
        new CRW_MetadataService.Metadata();
        new CRW_MetadataService.RetrieveMessage();
        new CRW_MetadataService.SessionHeader_element();
        new CRW_MetadataService.DeployOptions();
        new CRW_MetadataService.PackageTypeMembers();
        new CRW_MetadataService.PicklistValue();
        new CRW_MetadataService.deploy_element();
        new CRW_MetadataService.retrieveResponse_element();
        new CRW_MetadataService.checkRetrieveStatusResponse_element();
        new CRW_MetadataService.DebuggingInfo_element();
        new CRW_MetadataService.Package_x();
        new CRW_MetadataService.Error();
        new CRW_MetadataService.SaveResult();
        new CRW_MetadataService.createMetadataResponse_element();
        new CRW_MetadataService.LookupFilter();
        new CRW_MetadataService.createMetadata_element();
        new CRW_MetadataService.readMetadata_element();
        new CRW_MetadataService.ReadCustomFieldResult();
        new CRW_MetadataService.readCustomFieldResponse_element();
        new CRW_MetadataService.DeleteResult();
        new CRW_MetadataService.upsertMetadata_element();
        new CRW_MetadataService.upsertMetadataResponse_element();
        new CRW_MetadataService.UpsertResult();
        new CRW_MetadataService.describeValueType_element();
        new CRW_MetadataService.DescribeValueTypeResult();
        new CRW_MetadataService.PicklistEntry();
        new CRW_MetadataService.ValueTypeField();
        new CRW_MetadataService.AllOrNoneHeader_element();
        new CRW_MetadataService.GlobalPicklistValue();
        new CRW_MetadataService.PicklistValue();
        new CRW_MetadataService.ValueSetValuesDefinition();
        new CRW_MetadataService.ValueSet();
        new CRW_MetadataService.ValueSettings();
    }

    @IsTest
    private static void elfMissingGetResultTest() { // elf patch
    	new CRW_MetadataService.readCustomFieldResponse_element().getResult();
    }
}