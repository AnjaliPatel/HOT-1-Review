global with sharing class CompleteAllInstallmentsClass{
    webservice static String completeOpenInstallments(Id donationID,String donationOwnerEmail){
        Integer countInstallment=0;
        Decimal totalAmountClosed=0.0;
        List<Opportunity> relatedInstallmentRecords=[SELECT Id
                                                          , Payment_Status__c
                                                          , Balance_Amount__c
                                                          , Installment_Amount__c
                                                       FROM Opportunity
                                                      WHERE Donation__c=:donationID
                                                        AND Payment_Status__c='Open'];
        for(Opportunity objInstallment: relatedInstallmentRecords){
            totalAmountClosed+=objInstallment.Installment_Amount__c;
            objInstallment.Balance_Amount__c=0;
            objInstallment.Payment_Status__c='Completed';
            countInstallment++;
        }
        //Updating the installment records.
        try{
            update relatedInstallmentRecords;
        }
        catch(Exception e){
            return e.getMessage();
        }
        
        Messaging.SingleEmailMessage donationMail = new Messaging.SingleEmailMessage();
        String[] recipient=new String[]{donationOwnerEmail};
        donationMail.setToAddresses(recipient); 
        donationMail.setSubject('Open Installments Completed.');
        donationMail.setPlainTextBody(countInstallment+' Installments completed'+'\n Amount Donated= '+totalAmountClosed);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {donationMail});
        String successMessage='Open Installments completed.';
        return successMessage;
    }
}