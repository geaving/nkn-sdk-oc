// Objective-C API for talking to nkn/utils Go package.
//   gobind -lang=objc nkn/utils
//
// File is generated by gobind. Do not edit.

#ifndef __Utils_H__
#define __Utils_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"

#include "Nkn.objc.h"
#include "Nkngomobile.objc.h"

FOUNDATION_EXPORT NSString* _Nonnull UtilsMeasureSeedRPCServer(NkngomobileStringArray* _Nullable seedRpcList, int32_t timeout, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT NkngomobileStringArray* _Nullable UtilsMeasureSeedRPCServerReturnStringArray(NkngomobileStringArray* _Nullable seedRpcList, int32_t timeout, NSError* _Nullable* _Nullable error);

#endif
