//This trigger creates the installment records for the donation records according to the donation period and payment frequency.
trigger OpporunityTrigger on Opportunity (after insert,
										  before update) {
    //This trigger should be initiated after insert of donation record.
    if(Trigger.isInsert && Trigger.isAfter){
    	if(checkRecursion.checkTriggerExecution()){
        OpporunityTriggerHandler.createInstallmentRecords(Trigger.New);
    	}
    }
    //This trigger should be initiated before the update of installment record.
    if(Trigger.isUpdate && Trigger.isBefore){
    	//if(checkRecursion.checkTriggerExecution()){
    		OpporunityTriggerHandler.updateInstallment(Trigger.new);
    	//}
    }    
    //This trigger should be initiated after the update of installment record.
  	
}