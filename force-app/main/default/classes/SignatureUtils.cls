// SingatureUtils.cls
public without sharing class SignatureUtils {
    
    @AuraEnabled
    public static void saveSignature(string relatedId, string data, string type){
        //No Id No save
        System.debug('Related '+relatedId);
        System.debug('data '+data);
        if(String.isBlank(relatedId)) return;
 
        if(type == 'Attachment'){
            saveAttachment(relatedId, data);
        }
 
        if(type == 'SFFile'){
            saveSFFile(relatedId,data);
        }
    }
 
    //Save file as Attachment
 	@testVisible
    private static void saveAttachment(Id relatedId, string data){
        Attachment att = new Attachment();
        att.Name = 'Signed-'+System.now().getTime()+'.png';
        att.Body = EncodingUtil.base64Decode(data);
        att.ContentType = 'image/png';
        att.ParentId = relatedId;
        System.debug('arelatedId'+relatedId); 
        insert att;
        System.debug('att .id '+att.id); 
    }
	
    @testVisible
    private static void saveSFFile(string relatedId, string data){
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'Singed-'+System.now().getTime()+'.png';
        cv.Title = 'Signed-'+Datetime.now()+'.png';
        cv.VersionData = EncodingUtil.base64Decode(data);
        //cv.PublishStatus = 'p';
        insert cv; 
 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [select contentDocumentId from ContentVersion where id=:cv.id].contentDocumentId;
        cdl.LinkedEntityId = relatedId;
        //cdl.ShareType = 'V'; 
        insert cdl;
    }
}