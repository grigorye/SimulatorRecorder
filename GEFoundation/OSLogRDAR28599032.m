//
//  OSLogRDAR28599032.m
//  GEBase
//
//  Created by Grigory Entin on 12.10.16.
//  Copyright © 2016 Grigory Entin. All rights reserved.
//

#import "OSLogRDAR28599032.h"
#import <Foundation/NSString.h>

#define os_log_with_type_and_dso(dso, log, type, format, ...) __extension__({ \
	if (os_log_type_enabled(log, type)) { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wvla\"") \
        OS_LOG_FORMAT_ERRORS \
        __attribute__((section("__TEXT,__oslogstring,cstring_literals"),internal_linkage)) static const char __format[] __asm(OS_STRINGIFY(OS_CONCAT(LOSLOG_, __COUNTER__))) = format; \
        uint8_t _os_log_buf[__builtin_os_log_format_buffer_size(format, ##__VA_ARGS__)]; \
        _os_log_impl(dso, log, type, __format, (uint8_t *) __builtin_os_log_format(_os_log_buf, format, ##__VA_ARGS__), (unsigned int) sizeof(_os_log_buf)); \
        _Pragma("clang diagnostic pop") \
	} \
})

void rdar_os_log_object_with_type(void const *dso, os_log_t log, os_log_type_t type, id object) {
	os_log_with_type_and_dso((void *)dso, log, type, "%{public}@", object);
}
