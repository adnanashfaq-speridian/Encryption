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
        
        Map<string, string> mapOfKeyAndData = new map<string, string>();
        map<string, blob> mapOfKeywithBlob = getKey();
        mapOfKeyAndData.put('Key', EncodingUtil.base64Encode(cryptoKey));
        for(string s : encryptedDataArray.keyset()){
          
            Blob data = Blob.valueOf(encryptedDataArray.get(s)); 
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data ); 
            string b64Data = EncodingUtil.base64Encode (encryptedData);            
            mapOfKeyAndData.put(s,b64Data);            
        }        
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
        return (string.isEmpty(expMsg) ?  mapOfDecryptedData :  null);  
    } 
}