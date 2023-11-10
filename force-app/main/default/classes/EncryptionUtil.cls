public with sharing class EncryptionUtil {
    public static Blob cryptoKey;
    public static Map<String, blob> encryptKey = new Map<String, blob>();
    public static string expMsg; 

    public static map<string, blob> getKey(){ 
        map<string, blob> mapOfStringwithBlob = new map<string, blob>();
        cryptoKey = Crypto.generateAesKey(128); 
        mapOfStringwithBlob.put(EncodingUtil.base64Encode(cryptoKey) , cryptoKey);
        return mapOfStringwithBlob;
    }

    @AuraEnabled(cacheable=true)
    public static map<string, string> processEncryption( map<string, string> encryptedDataArray){ 
        //system.debug('json== '+json);        
        //map<string, string> encryptedDataArray = (map<string, string>)json;
        
        Map<string, string> mapOfKeyAndData = new map<string, string>();
        system.debug('encryptedDataArray == '+encryptedDataArray); 
        map<string, blob> mapOfKeywithBlob = getKey();
        system.debug('cryptoKey -- '+EncodingUtil.base64Encode(cryptoKey));
        mapOfKeyAndData.put('Key', EncodingUtil.base64Encode(cryptoKey));
        for(string s : encryptedDataArray.keyset()){
          
            //encryptKey.put(recId, EncodingUtil.base64Encode(cryptoKey)); 
            Blob data = Blob.valueOf(encryptedDataArray.get(s)); 
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data ); 
            string b64Data = EncodingUtil.base64Encode (encryptedData);            
            
            mapOfKeyAndData.put(s,b64Data);            
        }        
        
        system.debug('mapOfKeyAndData == '+mapOfKeyAndData); 
        return mapOfKeyAndData; 
    } 

    @AuraEnabled(cacheable=true)
    public static Map<string, string> processDecryption(Map<string, string> mapOfEncryptedData, String key){ 

        String decryptedData; 
        Map<string, string> mapOfDecryptedData = new Map<string, string>();
        for(string encryptedValue : mapOfEncryptedData.keyset()){    

            Blob data = EncodingUtil.base64Decode(mapOfEncryptedData.get(encryptedValue)); 
            
            Blob privateKey = EncodingUtil.base64Decode(key);  
            
            try{ 
                Blob dataToDecrypt = Crypto.decryptWithManagedIV ('AES128', privateKey, data); 
                decryptedData = dataToDecrypt.toString(); 
                mapOfDecryptedData.put(encryptedValue , decryptedData);                
            }
                catch(Exception e){ 
                expMsg = e.getMessage();  
            }
        }
        system.debug('mapOfDecryptedData -- '+mapOfDecryptedData);
        return (string.isEmpty(expMsg) ?  mapOfDecryptedData :  null);  
    } 
}