#import "ImagePicker.h"
#import "ImagePicker-Swift.h"

@implementation ImagePicker {
    ImagePickerImpl *moduleImpl;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        moduleImpl = [ImagePickerImpl new];
    }
    return self;
}

RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeImagePickerSpecJSI>(params);
}

- (nonnull NSString *)getPermissionStatus {
    return [moduleImpl getPermissionStatus];
}

- (void)pickImage:(nonnull RCTResponseSenderBlock)onSuccess onError:(nonnull RCTResponseSenderBlock)onError {
    [moduleImpl pickImageOnSuccess:^(NSString * _Nonnull result) {
        onSuccess(@[result]);
    } onError:^(NSString * _Nonnull error) {
        onError(@[error]);
    }];
}

- (void)requestPermission:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject {
    [moduleImpl requestPermissionOnStatusChanged:^(NSString * _Nonnull status) {
        resolve(status);
    }];
}

@end
