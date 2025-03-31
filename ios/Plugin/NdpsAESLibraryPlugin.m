#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>
// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(NdpsAESLibraryPlugin, "NdpsAESLibrary",
           CAP_PLUGIN_METHOD(echo, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(NdpsEncryption, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(NdpsDecryption, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(NdpsSigatureGeneration, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(NdpsAipayPayments, CAPPluginReturnPromise);
)
