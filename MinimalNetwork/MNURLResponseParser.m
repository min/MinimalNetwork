//
//  MNURLResponseParser.m
//  MinimalNetwork
//
//  Created by Min Kim on 7/30/12.
//
//

#import "MNURLResponseParser.h"

@implementation MNURLResponseParser

+ (id)process:(NSData *)data {
  return data;
}

@end

@implementation MNJSONResponseParser

+ (id)process:(NSData *)data {
  return [NSJSONSerialization JSONObjectWithData:data
                                         options:kNilOptions
                                           error:nil];
}

@end

@implementation MNImageResponseParser

+ (id)process:(NSData *)data {
  return [UIImage imageWithData:data];
}

@end
