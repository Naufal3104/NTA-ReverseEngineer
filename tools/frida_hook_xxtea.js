// Frida script to hook XXTEA decryption and file operations in Cocos2d-x game
// Target: Ninety Thousand Acres (twgame.global.acers)

console.log("[*] Starting XXTEA key extraction script...");

// Hook fopen to see what JSC files are opened
const fopen = Module.findExportByName("libc.so", "fopen");
if (fopen) {
    Interceptor.attach(fopen, {
        onEnter: function(args) {
            this.filename = Memory.readUtf8String(args[0]);
            this.mode = Memory.readUtf8String(args[1]);
        },
        onLeave: function(retval) {
            if (this.filename && this.filename.indexOf(".jsc") !== -1) {
                console.log("[fopen] Opening JSC file:", this.filename, "mode:", this.mode);
            }
        }
    });
    console.log("[+] Hooked fopen");
}

// Hook fread to capture JSC file contents
const fread = Module.findExportByName("libc.so", "fread");
if (fread) {
    Interceptor.attach(fread, {
        onEnter: function(args) {
            this.buffer = args[0];
            this.size = args[1].toInt32();
            this.count = args[2].toInt32();
        },
        onLeave: function(retval) {
            const bytesRead = retval.toInt32() * this.size;
            if (bytesRead > 0 && bytesRead < 200) {
                const data = Memory.readByteArray(this.buffer, Math.min(bytesRead, 64));
                console.log("[fread]", bytesRead, "bytes, first 64:", hexdump(data, {length: 64}));
            }
        }
    });
    console.log("[+] Hooked fread");
}

// Search for XXTEA-related function signatures in libcocos2djs.so
const libcocos = Process.findModuleByName("libcocos2djs.so");
if (libcocos) {
    console.log("[+] Found libcocos2djs.so at:", libcocos.base);
    
    // Common XXTEA function patterns
    const patterns = [
        "xxtea_decrypt",
        "xxteaDecrypt", 
        "xxtea_decode",
        "decryptXXTEA",
        "XXTEA_decrypt",
        "setXXTEAKey",
        "xxteaKey",
        "_xxtea",
        "tea_decrypt"
    ];
    
    // Search for function names in exports
    const exports = libcocos.enumerateExports();
    console.log("[*] Searching", exports.length, "exports for XXTEA patterns...");
    
    exports.forEach(function(exp) {
        patterns.forEach(function(pattern) {
            if (exp.name.toLowerCase().indexOf(pattern.toLowerCase()) !== -1) {
                console.log("[!] FOUND potential XXTEA function:", exp.name, "at", exp.address);
            }
        });
    });
    
    // Search for string references to "xxtea" or "key"
    console.log("[*] Scanning libcocos2djs.so memory for string patterns...");
    const ranges = libcocos.enumerateRanges("r--");
    ranges.forEach(function(range) {
        try {
            Memory.scan(range.base, range.size, "78 78 74 65 61", { // "xxtea" in hex
                onMatch: function(address, size) {
                    console.log("[!] Found 'xxtea' string at:", address);
                    console.log(hexdump(address, {length: 32}));
                },
                onComplete: function() {}
            });
        } catch(e) {}
    });
}

// Hook malloc to see large allocations (might be decrypted JS buffer)
const malloc = Module.findExportByName("libc.so", "malloc");
if (malloc) {
    Interceptor.attach(malloc, {
        onEnter: function(args) {
            this.size = args[0].toInt32();
        },
        onLeave: function(retval) {
            // Log large allocations that might be decrypted JS
            if (this.size > 100000 && this.size < 2000000) {
                console.log("[malloc] Large allocation:", this.size, "bytes at", retval);
            }
        }
    });
    console.log("[+] Hooked malloc for large allocations");
}

// Hook potential decrypt functions by pattern matching ARM64 assembly
// Look for functions that take buffer + key + length parameters
if (libcocos) {
    console.log("[*] Scanning for decrypt-like functions...");
    
    // Search for common Cocos2d-x script loading functions
    const scriptPatterns = [
        "evalString",
        "runScript", 
        "executeScript",
        "ScriptingCore",
        "JSBCore",
        "se::ScriptEngine"
    ];
    
    exports.forEach(function(exp) {
        scriptPatterns.forEach(function(pattern) {
            if (exp.name.indexOf(pattern) !== -1) {
                console.log("[!] Script execution function:", exp.name, "at", exp.address);
                
                // Hook this function to see what scripts are executed
                try {
                    Interceptor.attach(exp.address, {
                        onEnter: function(args) {
                            console.log("[Script] Executing:", exp.name);
                            // Try to read first arg as string
                            try {
                                const str = Memory.readUtf8String(args[0]);
                                if (str && str.length < 200) {
                                    console.log("[Script] Code:", str.substring(0, 100));
                                }
                            } catch(e) {}
                        }
                    });
                    console.log("[+] Hooked", exp.name);
                } catch(e) {
                    console.log("[-] Failed to hook", exp.name, ":", e);
                }
            }
        });
    });
}

// Dump memory regions that might contain decrypted JS
console.log("[*] Use frida-trace or manual inspection to dump heap memory");
console.log("[*] Run: frida -U -n 'NINETY THOUSAND ACRES' -l dump_memory.js");
console.log("[*] Script loaded. Monitoring file operations and memory...");
