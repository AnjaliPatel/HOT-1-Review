@isTest
//This class if for testing the Oppotunity trigger handler
public class OpportunityTriggerHandlerTest{
    
    //This method tests for successful insert of opportunity.
    static testmethod void createInstallmentOnDonationInsertion(){
        Integer oppCount,lastCount;
        Account objAccount=new Account(Name='Collect Donation NGO');
        insert objAccount;
        String donationRecordTypeName=System.Label.Donation_Record_Type;
        String installmentRecordTypeName=System.Label.Installment_Record_Type;
        Id donationRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(donationRecordTypeName);
        Id installmentRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(installmentRecordTypeName);
        List<Opportunity> testOpportunities=CreateTestData.opportunityData(15,'Closed Won',500,true);
        for(oppCount=0;oppCount<5;oppCount++){                                  //This will create 60 installment records.
            testOpportunities[oppCount].Grand_Total_Donation_Amount__c=1200;
            testOpportunities[oppCount].Donation_Period_Years__c=1;
            testOpportunities[oppCount].Payment_Frequency__c='Monthly';
        }
        system.debug(oppCount);
        lastCount=oppCount;
        for(oppCount=lastCount;oppCount<7;oppCount++){                           //This will create 0 installment record.
            testOpportunities[oppCount].Grand_Total_Donation_Amount__c=1200;
            testOpportunities[oppCount].Donation_Period_Years__c=1;
            testOpportunities[oppCount].Payment_Frequency__c='One-Time';
        }
        system.debug(oppCount);
        lastCount=oppCount;
        for(oppCount=lastCount;oppCount<11;oppCount++){                           //This will create 16 install records
            testOpportunities[oppCount].Grand_Total_Donation_Amount__c=1200;
            testOpportunities[oppCount].Donation_Period_Years__c=1;
            testOpportunities[oppCount].Payment_Frequency__c='Quarterly';
        }
        system.debug(oppCount);
        lastCount=oppCount;
        for(oppCount=lastCount;oppCount<13;oppCount++){                            //This will create 4 installment records.
            testOpportunities[oppCount].Grand_Total_Donation_Amount__c=1200;
            testOpportunities[oppCount].Donation_Period_Years__c=1;
            testOpportunities[oppCount].Payment_Frequency__c='Half-Yearly';
        }
        system.debug(oppCount);
        lastCount=oppCount;
        for(oppCount=lastCount;oppCount<15;oppCount++){                            //This will create 2 installment records
            testOpportunities[oppCount].Grand_Total_Donation_Amount__c=1200;
            testOpportunities[oppCount].Donation_Period_Years__c=1;
            testOpportunities[oppCount].Payment_Frequency__c='Yearly';
        }
        system.debug(oppCount);
        Test.StartTest();
        insert testOpportunities;
        Test.StopTest();
        List<Opportunity> installments=[SELECT Id
                                            , RecordTypeId
                                         FROM Opportunity
                                        WHERE RecordTypeId=:installmentRecordTypeId];
        System.assertEquals(82,installments.size());
    }
    
    //This method tests for unsuccessful insert of opportunity.
    static testmethod void unsuccessfulDonationInsertion(){
        Integer oppCount,lastCount;
        Account objAccount=new Account(Name='Collect Donation NGO');
        insert objAccount;
        String donationRecordTypeName=System.Label.Donation_Record_Type;
        String installmentRecordTypeName=System.Label.Installment_Record_Type;
        Id donationRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(donationRecordTypeName);
        Id installmentRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(installmentRecordTypeName);
        List<Opportunity> testOpportunities=CreateTestData.opportunityData(1,'Closed Won',500,true);
        testOpportunities[0].Grand_Total_Donation_Amount__c=1200;
        testOpportunities[0].Donation_Period_Years__c=1;
        testOpportunities[0].Payment_Frequency__c='None';
        try{
            Test.StartTest();
            insert testOpportunities;
            Test.StopTest();
        }
         catch(Exception e){
            system.debug(e.getMessage());
            system.assert(e.getMessage().contains('Choose Payment Frequency...!'));
        }
    }
    
    //This testmethod tests for successful updation.
    static testmethod void successfulInstallmentUpdate(){
        Account objAccount=new Account(Name='Collect Donation NGO');
        insert objAccount;
        String donationRecordTypeName=System.Label.Donation_Record_Type;
        String installmentRecordTypeName=System.Label.Installment_Record_Type;
        Id donationRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(donationRecordTypeName);
        Id installmentRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(installmentRecordTypeName);
        List<Opportunity> updateInstallmentDonation=CreateTestData.opportunityData(1,'Closed Won',500,true);
        updateInstallmentDonation[0].Grand_Total_Donation_Amount__c=1200;
        updateInstallmentDonation[0].Donation_Period_Years__c=1;
        updateInstallmentDonation[0].Payment_Frequency__c='Quarterly';
        system.debug(updateInstallmentDonation);
        insert updateInstallmentDonation;
        system.debug(updateInstallmentDonation);
        List<Opportunity> installmentsCreated=[SELECT Id
                                                    , Donation__c
                                                    , Balance_Amount__c
                                                    , Installment_Amount__c
                                                    , Part_Payment__c
                                                    , Payment_Status__c
                                                 FROM Opportunity
                                                WHERE Donation__c=:updateInstallmentDonation[0].Id];
        system.debug(installmentsCreated);
        for(Opportunity objInstallment: installmentsCreated){
            objInstallment.Part_Payment__c=100.00;
        }
        Test.startTest();
        update installmentsCreated;
        List<Opportunity> installmentsUpdated=[SELECT Id
                                                    , Donation__c
                                                    , Balance_Amount__c
                                                    , Installment_Amount__c
                                                    , Part_Payment__c
                                                    , Payment_Status__c
                                                 FROM Opportunity
                                                WHERE Donation__c=:updateInstallmentDonation[0].Id];
        //update updateInstallmentDonation;
        system.debug(installmentsUpdated);
        Test.stopTest();
        for(Opportunity obj: installmentsUpdated){
            system.assertEquals(200,obj.Balance_Amount__c);
            system.assertEquals('Partially Completed',obj.Payment_Status__c);
        }
    }
    
    //This testmethod checks for the completed part payments on the installments.
    static testmethod void successfulCompletedInstallmentUpdate(){
        Account objAccount=new Account(Name='Collect Donation NGO');
        insert objAccount;
        String donationRecordTypeName=System.Label.Donation_Record_Type;
        String installmentRecordTypeName=System.Label.Installment_Record_Type;
        Id donationRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(donationRecordTypeName);
        Id installmentRecordTypeId=OpporunityTriggerHandlerHelper.getRecordTypeId(installmentRecordTypeName);
        List<Opportunity> updateInstallmentDonation=CreateTestData.opportunityData(1,'Closed Won',500,true);
        updateInstallmentDonation[0].Grand_Total_Donation_Amount__c=1200;
        updateInstallmentDonation[0].Donation_Period_Years__c=1;
        updateInstallmentDonation[0].Payment_Frequency__c='Quarterly';
        system.debug(updateInstallmentDonation);
        insert updateInstallmentDonation;
        system.debug(updateInstallmentDonation);
        List<Opportunity> installmentsCreated=[SELECT Id
                                                    , Donation__c
                                                    , Balance_Amount__c
                                                    , Installment_Amount__c
                                                    , Part_Payment__c
                                                    , Payment_Status__c
                                                 FROM Opportunity
                                                WHERE Donation__c=:updateInstallmentDonation[0].Id];
        system.debug(installmentsCreated);
        for(Opportunity objInstallment: installmentsCreated){
            objInstallment.Part_Payment__c=300.00;
        }
        Test.startTest();
        update installmentsCreated;
        List<Opportunity> installmentsUpdated=[SELECT Id
                                                    , Donation__c
                                                    , Balance_Amount__c
                                                    , Installment_Amount__c
                                                    , Part_Payment__c
                                                    , Payment_Status__c
                                                 FROM Opportunity
                                                WHERE Donation__c=:updateInstallmentDonation[0].Id];
        //update updateInstallmentDonation;
        system.debug(installmentsUpdated);
        Test.stopTest();
        for(Opportunity obj: installmentsUpdated){
            system.assertEquals(0,obj.Balance_Amount__c);
            system.assertEquals('Completed',obj.Payment_Status__c);
        }
    }
}