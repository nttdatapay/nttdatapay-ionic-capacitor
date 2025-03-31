package com.ndps.plugins.ndpsaeslibrary;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import android.content.Intent;
import androidx.activity.result.ActivityResult;
import com.getcapacitor.annotation.ActivityCallback;

@CapacitorPlugin(name = "NdpsAESLibrary")
public class NdpsAESLibraryPlugin extends Plugin {

    private NdpsAESLibrary implementation = new NdpsAESLibrary();

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");
        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }

    @PluginMethod
    public void NdpsAipayPayments(PluginCall call) {
        JSObject data = call.getObject("value", new JSObject());
        Intent intent = new Intent(getContext(), WebViewActivity.class);
        intent.putExtra("merchId", data.getString("merchId"));
        intent.putExtra("password", data.getString("password"));
        intent.putExtra("product", data.getString("product"));
        intent.putExtra("txnCurrency", data.getString("txnCurrency"));
        intent.putExtra("custAccNo", data.getString("custAccNo"));
        intent.putExtra("amount", data.getString("amount"));
        intent.putExtra("merchTxnId", data.getString("merchTxnId"));
        intent.putExtra("custFirstName", data.getString("custFirstName"));
        intent.putExtra("custEmail", data.getString("custEmail"));
        intent.putExtra("custMobile", data.getString("custMobile"));
        intent.putExtra("udf1", data.getString("udf1"));
        intent.putExtra("udf2", data.getString("udf2"));
        intent.putExtra("udf3", data.getString("udf3"));
        intent.putExtra("udf4", data.getString("udf4"));
        intent.putExtra("udf5", data.getString("udf5"));
        intent.putExtra("responseHashKey", data.getString("responseHashKey"));
        intent.putExtra("encryptionKey", data.getString("encryptionKey"));
        intent.putExtra("decryptionKey", data.getString("decryptionKey"));
        intent.putExtra("payMode", data.getString("payMode"));
        startActivityForResult(call, intent, "getResponseData");
    }

    // getting data from WebView and posting back to the ionic app
    @ActivityCallback
    private void getResponseData(PluginCall call, ActivityResult result) {
        if (call == null) {
            return;
        }
        Intent intent = result.getData();
        String response = intent.getStringExtra("response");
        JSObject results = new JSObject();
        results.put("value", response);
        bridge.triggerWindowJSEvent("ndps_pg_response", "{ 'response': '" + response + "' }");
        call.resolve(results);
    }

}
