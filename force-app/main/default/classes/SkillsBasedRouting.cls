/**
 * @description       : 
 * @author            : Rohan Gaikwad
 * @last modified on  : 10-05-2021
 * @last modified by  : Rohan Gaikwad
**/
global class SkillsBasedRouting {

    @InvocableMethod
    public static void routeUsingSkills(List<String> transcripts) {
        List<LiveChatTranscript> transcriptObjects = [SELECT Id, Visitor_FirstName__c, Visitor_LastName__c, Visitor_Email__c, Visitor_Language__c 
        FROM LiveChatTranscript WHERE Id in :transcripts];
        for (LiveChatTranscript transcriptObj : transcriptObjects) {
            try {
                // Create a PendingServiceRouting to initiate routing
                createPendingServiceRouting(transcriptObj);
            } catch(exception e) {
                System.debug('ERROR:' + e.getStackTraceString());
                throw e;
            }
        }
    }
    
    static void createPendingServiceRouting(LiveChatTranscript transcriptObj) {
        // Create a new SkillsBased PendingServiceRouting
        PendingServiceRouting psrObj = new PendingServiceRouting(
            CapacityWeight = 1,
            IsReadyForRouting = FALSE,
            RoutingModel  = 'MostAvailable',
            RoutingPriority = 1,
            RoutingType = 'SkillsBased',
            ServiceChannelId = getChannelId(),
            WorkItemId = transcriptObj.Id,
            PushTimeout = 0
        );
        insert psrObj;
        psrObj = [select id, IsReadyForRouting from PendingServiceRouting where id = : psrObj.id];
        System.debug('psrObj: ' + psrObj);
        // Now add SkillRequirement(s) to the PendingServiceRouting
        SkillRequirement srObj = new SkillRequirement(
            RelatedRecordId = psrObj.id,
            SkillId = getSkillId(transcriptObj.Visitor_Language__c),
            SkillLevel = 10
        );
        insert srObj;
        System.debug('srObj: ' + srObj);
        // Update PendingServiceRouting as IsReadyForRouting
        psrObj.IsReadyForRouting = TRUE;
        update psrObj; 
        System.debug('psrObj: ' + psrObj);
    }
    
    static String getChannelId() {
        ServiceChannel channel = [SELECT Id FROM ServiceChannel WHERE RelatedEntity = 'LiveChatTranscript'];
        return channel.Id;
    }
    
    static String getSkillId(String transcriptLanguage) {
        String skillName = 'Chinese';
        if (transcriptLanguage != null) {
            if (transcriptLanguage.contains('Spanish')) {
                skillName = 'Spanish';
            } else if (transcriptLanguage.contains('French')) {
                skillName = 'French';
            } else if (transcriptLanguage == 'zh_CN') {
                skillName = 'Chinese';
            }
        }
        Skill skill = [Select Id From Skill Where DeveloperName = :skillName];
        return skill.Id;
    }

}
// SkillsBasedRouting.routeUsingSkills(new String[]{'5703K000000dYXRQA2'});