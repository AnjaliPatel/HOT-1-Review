//This is the helper class of OpporunityTriggerHandler.
public class OpporunityTriggerHandlerHelper{
    //This method generates the Id of the Account whose name has been passed as the parameter.
    public static Id getRequiredAccountId(String accountName){
        Account objAccount=[SELECT Id                                                    //Extracting the Id of the Collect Donation NGO
                                 , Name
                              FROM Account
                             WHERE Name=:accountName];
        return objAccount.Id;
    } 
    //This method generates the Id of the record type whose name has been passed as the parameter.
    public static Id getRecordTypeId(String recordName){
        RecordType objRecordType=[SELECT Id                                  //Extracting the Id of the given Record Type
                                       , Name
                                    FROM RecordType
                                   WHERE Name=:recordName];
        return objRecordType.Id;
    }
    //This method creates the Installment Records according to the Donation Record.
   /* public static List<Opportunity> createInstallments(){
    	
    }*/ 
}