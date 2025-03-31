package com.ndps.plugins.ndpsaeslibrary;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Formatter;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;

public class WebViewActivity extends Activity {
    private String merchId;
    private String txnpassword;
    private String product;
    private String txnCurrency;
    private String custAccNo;
    private String amount;
    private String merchTxnId;
    private String encryptionKey;
    private String decryptionKey;
    private String responseHashKey;
    private String custFirstName;
    private String custEmail;
    private String custMobile;
    private String udf1;
    private String udf2;
    private String udf3;
    private String udf4;
    private String udf5;
    private String payMode;
    private String atomTokenId = "";
    private String checkIfTokenGenerated = null;
    private String encString = null;
    String ruparamval = "";

    private String password = "8E41C78439831010F81F61C344B7BFC7";
    private String salt = "8E41C78439831010F81F61C344B7BFC7";
    private static final String HMAC_SHA512 = "HmacSHA512";
    private static int pswdIterations = 65536;
    private static int keySize = 256;
    private final byte[] ivBytes = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle extras = getIntent().getExtras();
        merchId = extras.getString("merchId");
        txnpassword = extras.getString("password");
        product = extras.getString("product");
        txnCurrency = extras.getString("txnCurrency");
        custAccNo = extras.getString("custAccNo");
        amount = extras.getString("amount");
        merchTxnId = extras.getString("merchTxnId");
        responseHashKey = extras.getString("responseHashKey");
        encryptionKey = extras.getString("encryptionKey");
        decryptionKey = extras.getString("decryptionKey");
        custFirstName = extras.getString("custFirstName");
        custEmail = extras.getString("custEmail");
        custMobile = extras.getString("custMobile");
        udf1 = extras.getString("udf1");
        udf2 = extras.getString("udf2");
        udf3 = extras.getString("udf3");
        udf4 = extras.getString("udf4");
        udf5 = extras.getString("udf5");
        payMode = extras.getString("payMode");

        setContentView(R.layout.activity_webview);
        WebView webView = findViewById(R.id.aipayWebView);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);

        // get current date and time for each request
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        String date = dateFormat.format(new Date());

        String jsonData = "{\"payInstrument\": { \"headDetails\": { \"version\": \"OTSv1.1\", \"api\": \"AUTH\", \"platform\": \"FLASH\" }, \"merchDetails\": { \"merchId\": \""
                + merchId + "\", \"userId\": \"\", \"password\": \"" + txnpassword + "\", \"merchTxnId\": \""
                + merchTxnId + "\", \"merchTxnDate\": \"" + date + "\" }, \"payDetails\": { \"amount\": \"" + amount
                + "\", \"product\": \"" + product + "\", \"custAccNo\": \"" + custAccNo + "\", \"txnCurrency\": \""
                + txnCurrency + "\" }, \"custDetails\": { \"custFirstName\": \"" + custFirstName
                + "\", \"custEmail\": \"" + custEmail + "\", \"custMobile\": \"" + custMobile
                + "\" }, \"extras\": { \"udf1\":\"" + udf1 + "\", \"udf2\":\"" + udf2 + "\", \"udf3\":\"" + udf3
                + "\", \"udf4\":\"" + udf4 + "\", \"udf5\":\"" + udf5 + "\"}}}";

        try {
            System.out.println("jsonData:" + jsonData);
            encString = encrypt(jsonData, encryptionKey, encryptionKey);
            System.out.println("encrypted Value: " + encString);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("encrypted Value: " + e);
        }

        String payUrl = null;
        if (payMode.equals("uat")) {
            payUrl = "https://caller.atomtech.in/ots/aipay/auth";
        } else {
            payUrl = "https://payment1.atomtech.in/ots/aipay/auth";
        }

        final String URL = payUrl;
        System.out.println("PayMode : " + payMode + " | URL: " + URL);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, URL,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        System.out.println("AUTH API response: " + response);
                        final Intent returnIntent = new Intent();
                        try {
                            if (response != null && !response.isEmpty()) {
                                if (response.contains("merchId") && response.contains("encData")) {
                                    String[] separated = response.split("&");
                                    String[] getEncData = separated[1].split("="); // here
                                    String decryptedResponse = null;
                                    try {
                                        decryptedResponse = decrypt(getEncData[1], decryptionKey, decryptionKey);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                    JSONObject object = new JSONObject(decryptedResponse);
                                    atomTokenId = object.getString("atomTokenId");
                                    checkIfTokenGenerated = "true";
                                    System.out.println("atomTokenId generated= " + atomTokenId);
                                    String url = "";
                                    if (payMode.equals("uat")) {
                                        url = "file:///android_asset/aipay-uat.html";
                                    } else {
                                        url = "file:///android_asset/aipay-prod.html";
                                    }
                                    webView.setWebChromeClient(new WebChromeClient());
                                    webView.setWebViewClient(new WebViewClient() {
                                        public boolean shouldOverrideUrlLoading(WebView view, String url) {
                                            if (url.startsWith("upi:")) {
                                                try {
                                                    Intent intent = new Intent(Intent.ACTION_VIEW); // To show app
                                                                                                    // chooser
                                                    intent.setData(Uri.parse(url));
                                                    startActivity(intent);
                                                    return true;
                                                } catch (Exception e) {
                                                    System.out.println("No UPI app found!");
                                                }
                                            } else {
                                                view.loadUrl(url);
                                                return true;
                                            }
                                            return true;
                                        }

                                        public void onPageFinished(WebView view, String url) {
                                            System.out.println("url detected: " + url);
                                            if (url.contains("aipay-uat.html") || url.contains("aipay-prod.html")) {
                                                if (payMode.equals("uat")) {
                                                    ruparamval = "https://pgtest.atomtech.in/mobilesdk/param";
                                                } else {
                                                    ruparamval = "https://payment.atomtech.in/mobilesdk/param";
                                                }
                                                view.loadUrl("javascript:init('" + atomTokenId + "', '" + merchId
                                                        + "', '" + custEmail + "', '" + custMobile + "', '" + ruparamval
                                                        + "');");
                                            }

                                            if(url.contains("mobilesdk/param")){
                                                webView.evaluateJavascript(
                                                  "(function() { let htmlH5 = document.getElementsByTagName('h5')[0].innerHTML; return htmlH5; })();",
                                                  new ValueCallback<String>() {
                                                    @Override
                                                    public void onReceiveValue(String html) {
                                                      Log.d("HTML data = ", html);
                                                      String responseStr = null;
                                                      String postFinalResponseData = null;
                                                      String[] res = html.split("[|]", 0);
                                                      if(html.contains("cancelTransaction")) {
                                                        try {
                                                          postFinalResponseData = getCustomCancelMessage();
                                                        } catch (JSONException e) {
                                                          e.printStackTrace();
                                                        }
                                                      } else if(html.contains("upiIntentResponse")) {
                                                         String[] res2 = res[2].split("[=]", 0);
                                                         responseStr = res2[1];
                                                        try {
                                                          String replaceQuotes = responseStr.replace('"', ' ');
                                                          String decryptedString = decrypt(replaceQuotes.trim(), decryptionKey, decryptionKey);
                                                          postFinalResponseData = formatUPIResponse(decryptedString);
                                                        } catch (Exception e) {
                                                          e.printStackTrace();
                                                        }
                                                      }else{
                                                        String[] res2 = res[1].split("[=]", 0);
                                                        responseStr = res2[1];
                                                        try {
                                                          String replaceQuotes = responseStr.replace('"', ' ');
                                                          String decryptedString = decrypt(replaceQuotes.trim(), decryptionKey, decryptionKey);
                                                          postFinalResponseData = decryptedString;
                                                        } catch (Exception e) {
                                                          e.printStackTrace();
                                                        }
                                                      }
                                                      System.out.println("response post to ndps_pg_response event: " + postFinalResponseData);
                                                      returnIntent.putExtra("response", postFinalResponseData);
                                                      int code = 0;
                                                      setResult(code,returnIntent);
                                                      finish();
                                                    }
                                                  });
                                              }
                                        }
                                        public void onReceivedError(WebView view, int errorCode, String description,
                                                String failingUrl) {
                                            Toast.makeText(WebViewActivity.this, "Oh no! " + description,
                                                    Toast.LENGTH_SHORT).show();
                                        }
                                    });
                                    webView.loadUrl(url);
                                } else {
                                    returnIntent.putExtra("response", response);
                                    setResult(0, returnIntent);
                                    finish();
                                    System.out.println("merchId and encData does not exists");
                                }
                            } else {
                                returnIntent.putExtra("response", "Error in AUTH API: blank response received");
                                setResult(0, returnIntent);
                                finish();
                                System.out.println(
                                        "Blank response received from the AUTH API, kindly check your json data");
                            }
                        } catch (JSONException e) {
                            System.out.println("Data not received as expected");
                            checkIfTokenGenerated = "false";
                            e.printStackTrace();
                        }
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        checkIfTokenGenerated = "false";
                        Toast.makeText(WebViewActivity.this, "", Toast.LENGTH_SHORT).show();
                        System.out.println("AIPAY API error = " + error);
                    }
                }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                System.out.println("encString getParams = " + encString);
                HashMap<String, String> hashMap = new HashMap<String, String>();
                hashMap.put("merchId", merchId);
                hashMap.put("encData", encString);
                return hashMap;
            }
        };
        final RequestQueue requestQueue = Volley.newRequestQueue(this);
        requestQueue.add(stringRequest);
        requestQueue.addRequestFinishedListener(new RequestQueue.RequestFinishedListener<Object>() {
            @Override
            public void onRequestFinished(Request<Object> request) {
                requestQueue.getCache().clear();
            }
        });
    }

    public String encrypt(String plainText, String key, String merchantTxnId) throws Exception {
        this.password = key;
        this.salt = merchantTxnId;
        return encrypt(plainText);
    }

    private String encrypt(String plainText) throws Exception {
        byte[] saltBytes = this.salt.getBytes("UTF-8");
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
        PBEKeySpec spec = new PBEKeySpec(this.password.toCharArray(),
                saltBytes,
                pswdIterations,
                keySize);
        SecretKey secretKey = factory.generateSecret(spec);
        SecretKeySpec secret = new SecretKeySpec(secretKey.getEncoded(), "AES");
        IvParameterSpec localIvParameterSpec = new IvParameterSpec(this.ivBytes);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(1, secret, localIvParameterSpec);
        byte[] encryptedTextBytes = cipher.doFinal(plainText.getBytes("UTF-8"));
        return byteToHex(encryptedTextBytes);
    }

    public String decrypt(String encryptedText, String key, String merchantTxnId) throws Exception {
        this.password = key;
        this.salt = merchantTxnId;
        return decrypt(encryptedText);
    }

    private String byteToHex(byte[] byData) {
        StringBuffer sb = new StringBuffer(byData.length * 2);
        for (int i = 0; i < byData.length; ++i) {
            int v = byData[i] & 0xFF;
            if (v < 16)
                sb.append('0');
            sb.append(Integer.toHexString(v));
        }
        return sb.toString().toUpperCase();
    }

    private String decrypt(String encryptedText) throws Exception {
        byte[] saltBytes = this.salt.getBytes("UTF-8");
        byte[] encryptedTextBytes = hex2ByteArray(encryptedText);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
        PBEKeySpec spec = new PBEKeySpec(
                this.password.toCharArray(),
                saltBytes,
                pswdIterations,
                keySize);
        SecretKey secretKey = factory.generateSecret(spec);
        SecretKeySpec secret = new SecretKeySpec(secretKey.getEncoded(), "AES");
        IvParameterSpec localIvParameterSpec = new IvParameterSpec(this.ivBytes);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(2, secret, localIvParameterSpec);
        byte[] decryptedTextBytes = (byte[]) null;
        decryptedTextBytes = cipher.doFinal(encryptedTextBytes);
        return new String(decryptedTextBytes);
    }

    private byte[] hex2ByteArray(String sHexData) {
        byte[] rawData = new byte[sHexData.length() / 2];
        for (int i = 0; i < rawData.length; ++i) {
            int index = i * 2;
            int v = Integer.parseInt(sHexData.substring(index, index + 2).trim(), 16);
            rawData[i] = (byte) v;
        }

        return rawData;
    }

    private static String toHexStringHmac(byte[] bytes) {
        Formatter formatter = new Formatter();
        for (byte b : bytes) {
            formatter.format("%02x", b);
        }
        return formatter.toString();
    }

    // Prompt confirm box when user press the back button from payment page
    @Override
    public void onBackPressed() {
        new AlertDialog.Builder(this)
                .setIcon(android.R.drawable.ic_dialog_alert)
                .setTitle("Cancel Transaction")
                .setMessage("Do you want to cancel the transaction?")
                .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        finish();
                    }
                })
                .setNegativeButton("Cancel", null)
                .show();
    }
    
    public String getCustomCancelMessage() throws JSONException {
        String postCustomCancelMsg = null;
        JSONObject json = new JSONObject();
        JSONObject payInstrumentJson = new JSONObject();
        JSONObject item = new JSONObject();
        item.put("statusCode", "OTS0101");
        item.put("message", "CANCELLED");
        item.put("description", "TRANSACTION IS CANCELLED BY USER ON PAYMENT PAGE.");
        json.put("responseDetails", item);
        payInstrumentJson.put("payInstrument", json);
        postCustomCancelMsg = payInstrumentJson.toString();
        return postCustomCancelMsg;
    }

    public String formatUPIResponse(String decryptedString) throws JSONException {
        JSONObject jsonObj = new JSONObject(decryptedString);
        JSONArray jsonArray = (JSONArray) jsonObj.get("payInstrument");
        String upiJsonResponse = null;
        for (int i = 0; i <jsonArray.length(); i++) {
          try {
              JSONObject json = new JSONObject();
              JSONObject payInstrumentJson = new JSONObject();
              JSONObject item = new JSONObject();
              json.put("settlementDetails", ((JSONObject)jsonArray.get(i)).get("settlementDetails"));
              json.put("merchDetails", ((JSONObject)jsonArray.get(i)).get("merchDetails"));
              json.put("payDetails", ((JSONObject)jsonArray.get(i)).get("payDetails"));
              json.put("payModeSpecificData", ((JSONObject)jsonArray.get(i)).get("payModeSpecificData"));
              json.put("responseDetails", ((JSONObject)jsonArray.get(i)).get("responseDetails"));
              JSONObject subChannel =  jsonArray.getJSONObject(0).getJSONObject("payModeSpecificData");
              JSONArray array = new JSONArray();
              array.put("upi");
              subChannel.put("subChannel",array);
              payInstrumentJson.put("payInstrument", json);
              upiJsonResponse = payInstrumentJson.toString();
            } catch (JSONException e) {
              e.printStackTrace();
            }
        }
        return upiJsonResponse;
    }
}
