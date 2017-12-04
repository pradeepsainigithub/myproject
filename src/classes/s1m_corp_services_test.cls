/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class s1m_corp_services_test {

    static testMethod void tests1m_corp_services() {
        
        Profile pro = [select id from profile where name='Standard User'];
		User p = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8', lastname='Testing', 
		languagelocalekey='en_US',localesidkey='en_US', profileid = pro.Id,timezonesidkey='America/Los_Angeles', Phone='555-123-1234',
		username='standarduser@testorg2.com');
		insert p;

        S1M_Corporate_Office__c co = new S1M_Corporate_Office__c(Name='Boston', S1M_Location__Latitude__s=Decimal.valueOf('42.350468'),
        S1M_Location__Longitude__s=Decimal.valueOf('-71.074126'));
        insert co;
        
        S1M_Corp_Services__c csCity = new S1M_Corp_Services__c(S1M_Corporate_Office__c=co.Id, Name='Fitness Power',
        S1M_Type__c = 'Fitness', S1M_Provider__c='Internal', S1M_Person__c=p.Id, S1M_Description__c='Get buff', S1M_Service_Region__c='City');
		insert csCity;
				
        S1M_Corp_Services__c csGlobal = new S1M_Corp_Services__c(S1M_Corporate_Office__c=co.Id, Name='HR',
        S1M_Type__c = 'Service', S1M_Provider__c='Internal', S1M_Person__c=p.Id, S1M_Description__c='Get process', S1M_Service_Region__c='Global');
		insert csGlobal;

        S1M_Corp_Services__c csOffice = new S1M_Corp_Services__c(S1M_Corporate_Office__c=co.Id, Name='Front Desk',
        S1M_Type__c = 'Font Desk', S1M_Provider__c='Internal', S1M_Person__c=p.Id, S1M_Description__c='Call if you need anything', 
        S1M_Service_Region__c='Campus or Office');
		insert csOffice;
		
        S1M_Corp_Services__c csCity2 = new S1M_Corp_Services__c(S1M_Corporate_Office__c=co.Id, Name='Fitness Power',
        S1M_Type__c = 'Fitness', S1M_Provider__c='External', S1M_City__c='Boston', S1M_Contact_Not_User__c='Mike Wrench', S1M_Phone__c='555-555-5555', 
        S1M_Description__c='Get buff', S1M_Service_Region__c='City');
		insert csCity2;
				
        S1M_Corp_Services__c csOffice2 = new S1M_Corp_Services__c(S1M_Corporate_Office__c=co.Id, Name='Maintenance',
        S1M_Type__c = 'Maintenance', S1M_Provider__c='External', S1M_City__c='Boston', S1M_Contact_Not_User__c='Mike Wrench', S1M_Phone__c='555-555-5555', 
        S1M_Description__c='Service for any office related needs', 
        S1M_Service_Region__c='Campus or Office');
		insert csOffice2;
		

		// START Testing from Live Example code...
		
		s1m_corp_services.CorpServices myServices = new s1m_corp_services.CorpServices();

		String myLat = '42.350468'; //String.valueOf(clat);
		String myLon = '-71.074126'; //String.valueOf(clong);
		
		Decimal myLatd = Decimal.valueOf('42.350468');
		Decimal myLond = Decimal.valueOf('-71.074126');
		
		List<S1M_Corporate_Office__c> corpOffices = Database.query('SELECT Id,Name,S1M_Location__Latitude__s,S1M_Location__Longitude__s FROM S1M_Corporate_Office__c WHERE DISTANCE(S1M_Location__c, GEOLOCATION(' + myLat +', ' + myLon + '), \'mi\') < 500 ORDER BY DISTANCE(S1M_Location__c, GEOLOCATION(' + myLat + ', ' + myLon + '), \'mi\') LIMIT 1');

		myServices.nearestOfficeId = corpOffices[0].Id;
		myServices.nearestOfficeName = corpOffices[0].Name;
			
		// Get any services that are bound to the closest office
    	String qOfficeServices = 'SELECT Id,Name, S1M_Address__c,S1M_City__c,S1M_Contact_Not_User__c,S1M_Description__c, S1M_Provider__c,' +
    	'S1M_Person__c,S1M_Person__r.Name,S1M_Phone__c, S1M_Service_Region__c, S1M_Type__c, S1M_Person__r.SmallPhotoUrl, S1M_Person__r.Phone, ' + 
    	'S1M_Person__r.MobilePhone FROM S1M_Corp_Services__c WHERE S1M_Corporate_Office__c = \'' + myServices.nearestOfficeId + '\' LIMIT 50';
		
		
			List<s1m_corp_services.ServiceDetail> myOfficeServices = new List<s1m_corp_services.ServiceDetail>();	
    	
			for (S1M_Corp_Services__c serviceLine : [SELECT Id,Name, S1M_Address__c,S1M_City__c,S1M_Contact_Not_User__c,S1M_Description__c, 
			S1M_Provider__c, S1M_Person__c,S1M_Person__r.Name,S1M_Phone__c, S1M_Service_Region__c, S1M_Type__c, S1M_Person__r.SmallPhotoUrl, 
			S1M_Person__r.Phone, S1M_Person__r.MobilePhone FROM S1M_Corp_Services__c WHERE S1M_Corporate_Office__c = :myServices.nearestOfficeId  
			AND S1M_Service_Region__c = 'Campus or Office' LIMIT 50]) {	  

			  	s1m_corp_services.ServiceDetail myServiceDetail = new s1m_corp_services.ServiceDetail();
			  	
			  	myServiceDetail.servicename = serviceLine.Name;
			  	myServiceDetail.servicetype = serviceLine.S1M_Type__c;
			  	myServiceDetail.id = serviceLine.Id;
			  	myServiceDetail.provider = serviceLine.S1M_Provider__c;
			  	myServiceDetail.servicedescription = serviceLine.S1M_Description__c;
			  	
			  	if (String.valueOf(serviceLine.S1M_Provider__c) == 'External')
			  	{
			  		myServiceDetail.contactname = serviceLine.S1M_Contact_Not_User__c;
			  		myServiceDetail.phone = serviceLine.S1M_Phone__c;
			  		myServiceDetail.photo = null;
			  	}
			  	else
			  	{
			  		myServiceDetail.contactname = serviceLine.S1M_Person__r.Name;
			  		myServiceDetail.phone = serviceLine.S1M_Person__r.Phone;
			  		myServiceDetail.photo = serviceLine.S1M_Person__r.SmallPhotoUrl;
			  	}			  	
			  	
			  	
				myOfficeServices.add(myServiceDetail);

		  	}
		  	
		  	myServices.officeServices = myOfficeServices;
		  	
		// Set default of X mi for city
		String distCity = '30';

    	String qCityServices = 'SELECT Id, Name,' + 
    	'S1M_Address__c,S1M_City__c,S1M_Contact_Not_User__c,S1M_Country__c,S1M_Description__c,S1M_Location__Latitude__s,' +
    	'S1M_Location__Longitude__s,S1M_Provider__c,S1M_Person__c,S1M_Phone__c,S1M_Postal_Code__c,S1M_Service_Region__c,' +
    	'S1M_State__c,S1M_Type__c,SystemModstamp, S1M_Person__r.SmallPhotoUrl, S1M_Person__r.Name, S1M_Person__r.Phone, ' + 
    	'S1M_Person__r.MobilePhone FROM S1M_Corp_Services__c WHERE S1M_Service_Region__c = \'City\' AND ' +
    	'DISTANCE(S1M_Location__c, GEOLOCATION(' + myLat + ', ' + myLon + '), \'mi\') < ' + distCity + ' ' + 
		'ORDER BY DISTANCE(S1M_Location__c, GEOLOCATION(' + myLat + ', ' + myLon + '), \'mi\') ' +
		'LIMIT 50';
		
			List<s1m_corp_services.ServiceDetail> myCityServices = new List<s1m_corp_services.ServiceDetail>();
		
    		 for(S1M_Corp_Services__c cityLine : Database.query(qCityServices)) {	    	
			  	s1m_corp_services.ServiceDetail myCityDetail = new s1m_corp_services.ServiceDetail();
			  	
			  	myCityDetail.servicename = cityLine.Name;
			  	myCityDetail.servicetype = cityLine.S1M_Type__c;
			  	myCityDetail.id = cityLine.Id;
			  	myCityDetail.provider = cityLine.S1M_Provider__c;	  
			  	myCityDetail.servicedescription = cityLine.S1M_Description__c;	
			  	
			  	if (String.valueOf(cityLine.S1M_Provider__c) == 'External')
			  	{
			  		myCityDetail.contactname = cityLine.S1M_Contact_Not_User__c;
			  		myCityDetail.phone = cityLine.S1M_Phone__c;
			  		myCityDetail.photo = null;
			  	}
			  	else
			  	{
			  		myCityDetail.contactname = cityLine.S1M_Person__r.Name;
			  		myCityDetail.phone = cityLine.S1M_Person__r.Phone;
			  		myCityDetail.photo = cityLine.S1M_Person__r.SmallPhotoUrl;
			  	}	

			  	myCityServices.add(myCityDetail);
		  	}
		  	
		  	myServices.cityServices = myCityServices;
		

    	String qGlobalServices = 'SELECT Name, S1M_Address__c,S1M_City__c,S1M_Contact_Not_User__c,S1M_Country__c,S1M_Description__c,S1M_Location__Latitude__s,' +
    	'S1M_Location__Longitude__s,S1M_Provider__c,S1M_Mapping_Status__c,S1M_Person__c,S1M_Phone__c,S1M_Postal_Code__c,S1M_Service_Region__c,' +
    	'S1M_State__c,S1M_Type__c, S1M_Person__r.SmallPhotoUrl, S1M_Person__r.Name, S1M_Person__r.Phone, S1M_Person__r.MobilePhone FROM S1M_Corp_Services__c ' + 
    	'WHERE S1M_Service_Region__c = \'Global\' ORDER BY S1M_Type__c LIMIT 50';
		
		
			List<s1m_corp_services.ServiceDetail> myGlobalServices = new List<s1m_corp_services.ServiceDetail>();
		
    		 for(S1M_Corp_Services__c serviceGlobalLine : Database.query(qGlobalServices)) {	    	
			  	
			  	s1m_corp_services.ServiceDetail myGlobalDetail = new s1m_corp_services.ServiceDetail();
			  	
			  	myGlobalDetail.servicename = serviceGlobalLine.Name;
			  	myGlobalDetail.servicetype = serviceGlobalLine.S1M_Type__c;
			  	myGlobalDetail.id = serviceGlobalLine.Id;
			  	myGlobalDetail.provider = serviceGlobalLine.S1M_Provider__c;	 
			  	myGlobalDetail.servicedescription = serviceGlobalLine.S1M_Description__c;
			  	 	
			  	
			  	if (String.valueOf(serviceGlobalLine.S1M_Provider__c) == 'External')
			  	{
			  		myGlobalDetail.contactname = serviceGlobalLine.S1M_Contact_Not_User__c;
			  		myGlobalDetail.phone = serviceGlobalLine.S1M_Phone__c;
			  		myGlobalDetail.photo = null;
			  	}
			  	else
			  	{
			  		myGlobalDetail.contactname = serviceGlobalLine.S1M_Person__r.Name;
			  		myGlobalDetail.phone = serviceGlobalLine.S1M_Person__r.Phone;
			  		myGlobalDetail.photo = serviceGlobalLine.S1M_Person__r.SmallPhotoUrl;
			  	}

				myGlobalServices.add(myGlobalDetail);

		  	}
		  			  	
		  	myServices.globalServices = myGlobalServices;
		
		// END Code from Live Example...
		
		List<s1m_corp_services.ServiceDetail> testOfficeServices = new List<s1m_corp_services.ServiceDetail>();
		testOfficeServices = s1m_corp_services.getLocalServices(myLatd, myLond, '10').officeServices;

		List<s1m_corp_services.ServiceDetail> testGlobalServices = new List<s1m_corp_services.ServiceDetail>();
		testGlobalServices = s1m_corp_services.getLocalServices(myLatd, myLond, '10').globalServices;

		
		System.assertEquals(testGlobalServices[0].provider, myServices.globalServices[0].provider);
		
	
		s1m_corp_services.ServiceDetail testDetail = new s1m_corp_services.ServiceDetail();
		
		testDetail.contactname = 'bob';
		testDetail.phone = '555';
		testDetail.email = 'bob@aol.com';
		testDetail.servicename = 'servco';
		
		System.assertEquals(testDetail.contactname, 'bob');
		System.assertEquals(testDetail.phone, '555');
		System.assertEquals(testDetail.email, 'bob@aol.com');
		System.assertEquals(testDetail.servicename, 'servco');
		
    	
    }
}