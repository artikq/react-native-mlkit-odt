#import "MlkitOdt.h"
#import <React/RCTBridge.h>
#import <React/RCTLog.h>

#import <CoreGraphics/CoreGraphics.h>
#import <GoogleMLKit/MLKit.h>

@implementation MlkitOdt

RCT_EXPORT_MODULE()

static NSString *const detectionNoResultsMessage = @"Something went wrong";

NSDictionary* makeBoundingResult(CGRect frame) {
    return @{
       @"originY": @(frame.origin.y),
       @"originX": @(frame.origin.x),
       @"width": @(frame.size.width),
       @"height": @(frame.size.height)
   };
}

NSMutableArray* makeOutputResult(NSArray<MLKObject *> *objects) {
    NSMutableArray *output = [NSMutableArray array];
    if (objects == nil) {
      return output;
    }
    for (MLKObject *object in objects) {
        NSMutableDictionary *detectedObject = [NSMutableDictionary dictionary];
        detectedObject[@"bounding"] = makeBoundingResult(object.frame);
        if (object.trackingID != nil) {
          detectedObject[@"trackingID"] = object.trackingID;
        }
        NSMutableArray *labels = [NSMutableArray array];
        for (MLKObjectLabel *label in object.labels) {
            NSMutableDictionary *resultLabel = [NSMutableDictionary dictionary];
            resultLabel[@"text"] = label.text;
            resultLabel[@"confidence"] = @(label.confidence).stringValue;
            resultLabel[@"index"] = @(label.index).stringValue;
            [labels addObject:resultLabel];
        }
        detectedObject[@"labels"] = labels;
        [output addObject:detectedObject];
    }
    return output;
}


RCT_REMAP_METHOD(detectFromUri, detectFromUri:(NSString *)imagePath singleImage:(nonnull NSNumber*)isSingle classification:(nonnull NSNumber*)enableClassification multiDetect:(nonnull NSNumber*)enableMultidetect resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        RCTLog(@"No image uri provided");
        reject(@"wrong_arguments", @"No image uri provided", nil);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
        UIImage *image = [UIImage imageWithData:imageData];

        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                RCTLog(@"No image found %@", imagePath);
                reject(@"no_image", @"No image path provided", nil);
            });
            return;
        }
        MLKObjectDetectorOptions *options = [MLKObjectDetectorOptions new];
        if ([isSingle isEqualToNumber:@1]) {
          options.detectorMode = MLKObjectDetectorModeSingleImage;
        }
        if ([enableClassification isEqualToNumber:@1]) {
          options.shouldEnableClassification = YES;
        } else {
          options.shouldEnableClassification = NO;
        }

        if ([enableMultidetect isEqualToNumber:@1]) {
          options.shouldEnableMultipleObjects = YES;
        } else {
          options.shouldEnableMultipleObjects = NO;
        }
        MLKObjectDetector *detector = [MLKObjectDetector objectDetectorWithOptions:options];
        MLKVisionImage *handler = [[MLKVisionImage alloc] initWithImage:image];
        handler.orientation = image.imageOrientation;

        [detector processImage:handler completion:^(NSArray<MLKObject *> *_Nullable result, NSError *_Nullable error) {
            @try {
                if (error != nil || result == nil) {
                    NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
                    @throw [NSException exceptionWithName:@"failure" reason:errorString userInfo:nil];
                    return;
                }
                NSMutableArray *output = makeOutputResult(result);
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolve(output);
                });
            }
            @catch (NSException *e) {
                NSString *errorString = e ? e.reason : detectionNoResultsMessage;
                NSDictionary *pData = @{
                                        @"error": [NSMutableString stringWithFormat:@"On-Device object detection failed with error: %@", errorString],
                                        };
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolve(pData);
                });
            }
        }];

    });

}

@end
