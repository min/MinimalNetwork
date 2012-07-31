//
//  MNURLResponseParser.h
//  MinimalNetwork
//
//  Created by Min Kim on 7/30/12.
//
//
#import <UIKit/UIKit.h>

@interface MNURLResponseParser : NSObject

+ (id)process:(NSData *)data;

@end

@interface MNJSONResponseParser : MNURLResponseParser

@end

@interface MNImageResponseParser : MNURLResponseParser

@end
