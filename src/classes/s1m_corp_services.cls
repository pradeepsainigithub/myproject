public with sharing class s1m_corp_services {

    List<S1M_Corp_Services__c> localServices {get; set;}
    
    public s1m_corp_services() { } // empty constructor

	public class ServiceDetail {
		public String contactname {
			get {return contactname; }
			set {contactname = value; }						
		}
		public String phone {
			get {return phone; }
			set {phone = value; }						
		}
		public String photo {
			get {return photo; }
			set {photo = value; }						
		}
		public String email {
			get {return email; }
			set {email = value; }						
		}
		public String servicetype {
			get {return servicetype; }
			set {servicetype = value; }						
		}
		public String servicename {
			get {return servicename; }
			set {servicename = value; }						
		}
		public String servicedescription {
			get {return servicedescription; }
			set {servicedescription = value; }						
		}
		public String id {
			get {return id; }
			set {id = value; }						
		}
		public String provider {
			get {return provider; }
			set {provider = value; }
		}
			
		
	}

	public class CorpServices {
	   public String nearestOfficeName {
	      get { return nearestOfficeName; }
	      set { nearestOfficeName = value; }
	   }
	   public Id nearestOfficeId {
	      get { return nearestOfficeId; }
	      set { nearestOfficeId = value; }
	   }
	   public List<ServiceDetail> officeServices {
	      get { return officeServices; }
	      set { officeServices = value; }
	   }
	   public List<ServiceDetail> cityServices {
	      get { return cityServices; }
	      set { cityServices = value; }
	   }
	   public List<ServiceDetail> globalServices {
	      get { return globalServices; }
	      set { globalServices = value; }
	   }
	}


    @RemoteAction
    public static CorpServices getLocalServices(Decimal clat, Decimal clong, String dist) {

		CorpServices myServices = new CorpServices();

		String myLat = String.escapeSingleQuotes(String.valueOf(clat));
		String myLon = String.escapeSingleQuotes(String.valueOf(clong));
		dist = String.escapeSingleQuotes(dist);
		
		// Get closest office location and Id for use in later queries
		List<S1M_Corporate_Office__c> corpOffices = Database.query('SELECT Id,Name,S1M_Location__Latitude__s,S1M_Location__Longitude__s FROM S1M_Corporate_Office__c WHERE DISTANCE(S1M_Location__c, GEOLOCATION(' + myLat +', ' + myLon + '), \'mi\') < 500 ORDER BY DISTANCE(S1M_Location__c, GEOLOCATION(' + myLat + ', ' + myLon + '), \'mi\') LIMIT 1');

		myServices.nearestOfficeId = corpOffices[0].Id;
		myServices.nearestOfficeName = corpOffices[0].Name;
			
		// Get any services that are bound to the closest office
    	String qOfficeServices = 'SELECT Id,Name, S1M_Address__c,S1M_City__c,S1M_Contact_Not_User__c,S1M_Description__c, S1M_Provider__c,' +
    	'S1M_Person__c,S1M_Person__r.Name,S1M_Phone__c, S1M_Service_Region__c, S1M_Type__c, S1M_Person__r.SmallPhotoUrl, S1M_Person__r.Phone, ' + 
    	'S1M_Person__r.MobilePhone FROM S1M_Corp_Services__c WHERE S1M_Corporate_Office__c = \'' + String.escapeSingleQuotes(myServices.nearestOfficeId) + '\' LIMIT 50';
		
		
			List<ServiceDetail> myOfficeServices = new List<ServiceDetail>();	
    	
			for (S1M_Corp_Services__c serviceLine : [SELECT Id,Name, S1M_Address__c,S1M_City__c,S1M_Contact_Not_User__c,S1M_Description__c, 
			S1M_Provider__c, S1M_Person__c,S1M_Person__r.Name,S1M_Phone__c, S1M_Service_Region__c, S1M_Type__c, S1M_Person__r.SmallPhotoUrl, 
			S1M_Person__r.Phone, S1M_Person__r.MobilePhone FROM S1M_Corp_Services__c WHERE S1M_Corporate_Office__c = :myServices.nearestOfficeId  
			AND S1M_Service_Region__c = 'Campus or Office' LIMIT 50]) {	  

			  	ServiceDetail myServiceDetail = new ServiceDetail();
			  	
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
		
			List<ServiceDetail> myCityServices = new List<ServiceDetail>();
		
    		 for(S1M_Corp_Services__c cityLine : Database.query(qCityServices)) {	    	
			  	ServiceDetail myCityDetail = new ServiceDetail();
			  	
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
		
		
			List<ServiceDetail> myGlobalServices = new List<ServiceDetail>();
		
    		 for(S1M_Corp_Services__c serviceGlobalLine : Database.query(qGlobalServices)) {	    	
			  	
			  	ServiceDetail myGlobalDetail = new ServiceDetail();
			  	
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
		
		
		return myServices;
    }

}