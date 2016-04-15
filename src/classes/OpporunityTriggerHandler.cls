//This class acts as the handler class for the opportunity trigger.
public class OpporunityTriggerHandler{
		
    //This method takes the newly created donation records and creates the installment records related to it.
    public static void createInstallmentRecords(List <Opportunity> donationRecords){
        String NGOAccountName=System.Label.Account_Donor_Name;   
        String installmentRecordTypeName=System.Label.Installment_Record_Type;
        String donationRecordTypeName=System.Label.Donation_Record_Type;
        Id NGOAccountId=OpporunityTriggerHandlerHelper.getRequiredAccountId(NGOAccountName);
        Id donationRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(donationRecordTypeName);
        Id installmentRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(installmentRecordTypeName);
        List<Opportunity> installmentRecords=new List<Opportunity>();
        Integer numberOfInstallments;
        Date dueDate;
        Integer dayIncrement;
        Decimal singleInstallmentAmount;
        
        for(Opportunity objDonationOpportunity: donationRecords){
        	if(objDonationOpportunity.Payment_Frequency__c.equals('One-Time')){
              	numberOfInstallments=0;
            }
            else if(objDonationOpportunity.Payment_Frequency__c.equals('Monthly')){
               	numberOfInstallments=12*(Integer)objDonationOpportunity.Donation_Period_Years__c;
               	dayIncrement=30;
               	singleInstallmentAmount=objDonationOpportunity.Grand_Total_Donation_Amount__c/numberOfInstallments;
            }
            else if(objDonationOpportunity.Payment_Frequency__c.equals('Quarterly')){
               	numberOfInstallments=4*(Integer)objDonationOpportunity.Donation_Period_Years__c;
               	dayIncrement=90;
               	singleInstallmentAmount=objDonationOpportunity.Grand_Total_Donation_Amount__c/numberOfInstallments;
            }
            else if(objDonationOpportunity.Payment_Frequency__c.equals('Half-Yearly')){
               	numberOfInstallments=2*(Integer)objDonationOpportunity.Donation_Period_Years__c;
               	dayIncrement=120;
               	singleInstallmentAmount=objDonationOpportunity.Grand_Total_Donation_Amount__c/numberOfInstallments;
            }
            else if(objDonationOpportunity.Payment_Frequency__c.equals('Yearly')){
               	numberOfInstallments=1*(Integer)objDonationOpportunity.Donation_Period_Years__c;
               	dayIncrement=365;
               	singleInstallmentAmount=objDonationOpportunity.Grand_Total_Donation_Amount__c/numberOfInstallments;
            }
            else{
               	objDonationOpportunity.addError('Choose Payment Frequency...!');
            }
            dueDate=System.today();
            //singleInstallmentAmount=objDonationOpportunity.Grand_Total_Donation_Amount__c/numberOfInstallments;
            for(Integer installmentCount=0;installmentCount<numberOfInstallments;installmentCount++){
               	Opportunity objInstallment=new Opportunity();
               	objInstallment.RecordTypeId=installmentRecordTypeId;
               	objInstallment.Name='Installment '+installmentCount;
               	objInstallment.AccountId=NGOAccountId;
               	objInstallment.Payment_Status__c='Open';
               	objInstallment.Due_Payment_Date__c=dueDate;
               	objInstallment.Donation__c=objDonationOpportunity.Id;
               	objInstallment.Installment_Amount__c=singleInstallmentAmount.setScale(2);
               	objInstallment.CloseDate=System.today();
               	objInstallment.StageName='Closed Won';
               	objInstallment.Balance_Amount__c=objInstallment.Installment_Amount__c;
               	installmentRecords.add(objInstallment);
               	dueDate=dueDate+dayIncrement;
            }
            system.debug(installmentRecords);
        }
        if(installmentRecords.size()>0){
        	insert installmentRecords;
        }    
    }    
    
    //This method updates the installment record for the part payments of installment.
    public static void updateInstallment(List<Opportunity> partPaymentRecord){
    	system.debug(partPaymentRecord);
		String installmentRecordTypeName=System.Label.Installment_Record_Type;
        String donationRecordTypeName=System.Label.Donation_Record_Type;
        Id donationRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(donationRecordTypeName);
        Id installmentRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(installmentRecordTypeName);
        Id relatedDonationID;
		for(Opportunity objOpportunity: partPaymentRecord){
			if(objOpportunity.RecordTypeId.equals(installmentRecordTypeId)){
				if(objOpportunity.Balance_Amount__c>0){
					objOpportunity.Balance_Amount__c=objOpportunity.Balance_Amount__c-objOpportunity.Part_Payment__c;
					objOpportunity.Payment_Status__c='Partially Completed';
					objOpportunity.Part_Payment__c=0;
					if(objOpportunity.Balance_Amount__c==0){
						objOpportunity.Payment_Status__c='Completed';
						relatedDonationID=objOpportunity.Donation__c;
					}
				}
			}
		}
		/*List<AggregateResult> allInstallmentsList=[SELECT SUM(Balance_Amount__c) totalInstallment
												 	  FROM Opportunity
												     WHERE Donation__c=:relatedDonationID];
		Decimal installmentAmount;
		for(AggregateResult installment: allInstallmentsList){
			installmentAmount=(Decimal)installment.get('totalInstallment');	
		}
		system.debug(installmentAmount);
		List<Opportunity> objDonationRecord=[SELECT Id
											, Grand_Total_Donation_Amount__c
											, Payment_Status__c
									     FROM Opportunity
									    WHERE Id=:relatedDonationID];
		system.debug(objDonationRecord);
		if(installmentAmount==0.0){
			system.debug('--------------in If');
			objDonationRecord[0].Payment_Status__c='Completed';
			system.debug(objDonationRecord[0].Payment_Status__c);
		}
		else if(installmentAmount==objDonationRecord[0].Grand_Total_Donation_Amount__c){
			system.debug('--------------in ELSE If');
			objDonationRecord[0].Payment_Status__c='Open';
			system.debug(objDonationRecord[0].Payment_Status__c);
		}
		else{
			system.debug('--------------in Else');
			objDonationRecord[0].Payment_Status__c='Partially Completed';
			system.debug(objDonationRecord[0].Payment_Status__c);
		}*/
		//update objDonationRecord;
    } 
}