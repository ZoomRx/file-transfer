#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(FileTransfer, "FileTransfer",
           CAP_PLUGIN_METHOD(download, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(upload, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(abort, CAPPluginReturnPromise);
)
