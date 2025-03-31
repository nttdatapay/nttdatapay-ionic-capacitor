# nttdatapay-ionic-capacitor

# Ionic Capacitor NDPS payment gateway plugin
Ionic capacitor plugin for NTT DATA Payment Services India

## Install

```bash
npm install ndpsaeslibrary
npx cap sync
```

## Usage(Android, iOS)

```bash
// import NDPS payment gateway plugin
import { NdpsAESLibrary } from 'ndpsaeslibrary';

// initialize and call NDPS payment gateway plugin
const { NdpsAipayPayments } = NdpsAESLibrary;
const openWebViewUrl = await NdpsAipayPayments({ value: {
        "merchId": "317157",
        "password": "Test@123",
        "merchTxnId": "testtxn1234",
        "product": "NSE",
        "custAccNo": "213232323",
        "txnCurrency": "INR",
        "custFirstName": "testuser",
        "custEmail": "test@xyz.com",
        "custMobile": "8888888888",
        "amount": "1",
        "encryptionKey": "A4476C2062FFA58980DC8F79EB6A799E",
        "decryptionKey": "75AEF0FA1B94B3C10D4F5B268F757F11",
        "responseHashKey": "KEYRESP123657234",
        "udf1": "udf1",
        "udf2": "udf2",
        "udf3": "udf3",
        "udf4": "udf4",
        "udf5": "udf5",
        "payMode": "uat" // for production use change to live
      } });

    const NdpsAipayPaymentsFn = ndps_pg_response.bind(this);
    function ndps_pg_response(eventData: any) {
      window.removeEventListener('ndps_pg_response', NdpsAipayPaymentsFn);
      let parsedResponse = JSON.parse(eventData.response);
      if (parsedResponse['payInstrument']['responseDetails']['statusCode'] === "OTS0101") {
        console.log('Transaction has been cancelled by the user!');
      } else {
        if (parsedResponse['payInstrument']['responseDetails']['statusCode'] === "OTS0000" || parsedResponse['payInstrument']['responseDetails']['statusCode'] === "OTS0551") {
          console.log('Transaction Success');
        } else {
          console.log('Transaction Failed!')
        }
      }
    }
    window.addEventListener('ndps_pg_response', NdpsAipayPaymentsFn);
```

## Important Note: 
You need to add below lines inside your iOS app's info.plist file to support UPI Intent payment mode.

```bash
<key>LSApplicationQueriesSchemes</key> 
<array> 
 <string>upi</string> 
 <string>phonepe</string> 
 <string>paytmmp</string> 
 <string>gpay</string>
 <string>tez</string> 
</array>
