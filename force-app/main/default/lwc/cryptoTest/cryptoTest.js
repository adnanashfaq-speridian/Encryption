import { LightningElement , api, track } from 'lwc';
import processEncryption from '@salesforce/apex/EncryptionUtil.processEncryption';
import processDecryption from '@salesforce/apex/EncryptionUtil.processDecryption';


export default class CryptoTest extends LightningElement {
    
    encryptionKey='';
    bankRedirectUrl = 'test.salesforce.com';
    tokenId='dkjnaskdn2882992sdx';
    bankCode = 'Abl';
    availableBalance='109';
    creditSegmentCode = 'test';
    creditSegmentType='TESTS';
    applicationID='567896782';
    companyCode='090';
    amount='200';
    userId='23dsfaew231plo0';
    
    encryptedDataArrayObj;
    key='';

    obj = {
      'bankRedirectUrl': this.bankRedirectUrl,
      'tokenId': this.tokenId,
      'bankCode': this.bankCode,
      'availableBalance': this.availableBalance,
      'creditSegmentCode': this.creditSegmentCode,
      'creditSegmentType': this.creditSegmentType,
      'applicationID': this.applicationID,
      'companyCode': this.companyCode,
      'amount': this.amount,
      'userId': this.userId
    };

    connectedCallback(){
        this.encryptData();        
    }
    
    getValueFromObj(param) {
      return this.encryptedDataArrayObj[param];
    }

    encryptData(){
      processEncryption({ encryptedDataArray: this.obj }) 
      .then((result) => {
        this.encryptedDataArrayObj = result;
        for (var key in result) {
          if(key === 'Key'){
            this.encryptionKey = this.getValueFromObj(key);            
          }          
        }
        console.log('this.encryptionKey == '+this.encryptionKey);
      })
      .catch((error) => {
        console.log('in error == '+JSON.stringify(error));
        this.error = error;
      });
    }

    decryptData(){
      processDecryption({ mapOfEncryptedData: this.encryptedDataArrayObj , key : this.encryptionKey }) 
      .then((result) => {
        console.log('succes');
        this.obj= result;
        console.log('this obj '+JSON.stringify(this.obj));
      })
      .catch((error) => {
        console.log('error');
      });
    }
}