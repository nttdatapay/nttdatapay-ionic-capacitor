# Nttdatapay AIPAY Ionic Capacitor SDK

The **Nttdatapay AIPAY Ionic Capacitor SDK** allows integration of the Nttdatapay Payment Gateway into your application so you can start collecting payments seamlessly.

This plugin has been developed and tested on **Capacitor version 5.0**.

---

## 📦 Installation
```bash
npm install ndps-aipay-ionic-capacitor
npx cap sync
```

---

## 🚀 Usage (Android, iOS)

### Import the Nttdatapay payment gateway plugin
```ts
import { NdpsAipayLibrary } from 'ndps-aipay-ionic-capacitor';
```

### Initialize and call Nttdatapay payment gateway
```ts
const { NdpsAipayPayments } = NdpsAipayLibrary;
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
    "payMode": "uat" // for production use change to 'live'
}});
```

### Handling Payment Response
```ts
const NdpsAipayPaymentsFn = ndps_pg_response.bind(this);

function ndps_pg_response(eventData: any) {
  window.removeEventListener('ndps_pg_response', NdpsAipayPaymentsFn);

  let parsedResponse = JSON.parse(eventData.response);
  let statusCode = parsedResponse['payInstrument']['responseDetails']['statusCode'];

  if (statusCode === "OTS0101") {
    alert('Transaction has been cancelled by the user!');
  } else if (statusCode === "OTS0201") {
    alert('Session Timeout! Try again');
  } else {
    if (statusCode === "OTS0000" || statusCode === "OTS0551") {
      alert('Transaction Success');
    } else {
      alert('Transaction Failed!');
    }
  }
}

window.addEventListener('ndps_pg_response', NdpsAipayPaymentsFn);
```

---

## ⚠️ Important (iOS Only)
To support **UPI Intent** payment mode in iOS, add the following lines to your app's `info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>upi</string>
  <string>phonepe</string>
  <string>paytmmp</string>
  <string>gpay</string>
  <string>tez</string>
</array>
```

---

## ✅ You're all set!
You can now integrate and process payments using the Nttdatapay AIPAY Ionic Capacitor SDK.
