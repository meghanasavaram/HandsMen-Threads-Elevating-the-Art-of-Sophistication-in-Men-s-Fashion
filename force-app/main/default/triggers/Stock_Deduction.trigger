trigger Stock_Deduction on HandsMen_Order__c (after insert , after update) {
   Set<Id> productIds = new Set<Id>();
 
    for (HandsMen_Order__c order : Trigger.new) {
        if (order.Status__c == 'Confirmed' && order.HandsMen_Product__c != null) {
            productIds.add(order.HandsMen_Product__c);
        }
    }
 
    if (productIds.isEmpty()) return;

    Map<Id, Inventory__c> inventoryMap = new Map<Id, Inventory__c>(
        [SELECT Id, Stock_Quantity__c, HandsMen_Product__c 
         FROM Inventory__c 
         WHERE HandsMen_Product__c IN :productIds]
    );
 
    List<Inventory__c> inventoriesToUpdate = new List<Inventory__c>();
 
    for (HandsMen_Order__c order : Trigger.new) {
        if (order.Status__c == 'Confirmed' && order.HandsMen_Product__c != null) {
            for (Inventory__c inv : inventoryMap.values()) {
                if (inv.HandsMen_Product__c == order.HandsMen_Product__c) {
                    inv.Stock_Quantity__c -= order.Quantity__c;
                    inventoriesToUpdate.add(inv);
                    break;
                }
            }
        }
    }
 
    if (!inventoriesToUpdate.isEmpty()) {
        update inventoriesToUpdate;
    }
}