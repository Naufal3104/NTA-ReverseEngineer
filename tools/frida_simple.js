console.log("[*] Listing all loaded modules...");
Process.enumerateModules().forEach(function(mod) {
    if (mod.name.toLowerCase().indexOf("cocos") !== -1 || 
        mod.name.toLowerCase().indexOf("protect") !== -1 ||
        mod.name.toLowerCase().indexOf("xt4") !== -1) {
        console.log("[Module]", mod.name, "at", mod.base, "size:", mod.size);
    }
});

console.log("\n[*] Searching for XXTEA key in memory...");
const libcocos = Process.findModuleByName("libcocos2djs.so");
if (libcocos) {
    // Search for common key lengths (16, 24, 32 bytes)
    console.log("[*] Scanning libcocos2djs.so for potential keys...");
}
