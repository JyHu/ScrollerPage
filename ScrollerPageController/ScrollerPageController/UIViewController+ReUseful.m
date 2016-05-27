//
//  UIViewController+ReUseful.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/19.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "UIViewController+ReUseful.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation UIViewController (ReUseful)

const void *__reUsefulIdentifierKey = (void *)@"__reUsefulIdentifierKey";

- (void)setReUsefulIdentifier:(NSString *)reUsefulIdentifier
{
    objc_setAssociatedObject(self, __reUsefulIdentifierKey, reUsefulIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)reUsefulIdentifier
{
    return objc_getAssociatedObject(self, __reUsefulIdentifierKey);
}

const void *__cachedDataIdentifierKey = (void *)@"__cachedDataIdentifierKey";

- (void)setCacheMyData:(void (^)(NSString *, id))cacheMyData
{
    objc_setAssociatedObject(self, __cachedDataIdentifierKey, cacheMyData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSString *, id))cacheMyData
{
    return objc_getAssociatedObject(self, __cachedDataIdentifierKey);
}

const void *__uniquePageIdentifierKey = @"__uniquePageIdentifierKey";

- (void)setUniquePageTag:(NSUInteger)uniquePageTag
{
    objc_setAssociatedObject(self, __uniquePageIdentifierKey, @(uniquePageTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)uniquePageTag
{
    id obj = objc_getAssociatedObject(self, __uniquePageIdentifierKey);
    
    if (obj && [obj isKindOfClass:[NSNumber class]])
    {
        return [obj unsignedIntegerValue];
    }
    
    return NSNotFound;
}

const void *__optionalDataIdentifierKey = (void *)@"__optionalDataIdentifierKey";

- (void)setOptionalData:(id)optionalData
{
    objc_setAssociatedObject(self, __optionalDataIdentifierKey, optionalData, OBJC_ASSOCIATION_ASSIGN);
}

- (id)optionalData
{
    return objc_getAssociatedObject(self, __optionalDataIdentifierKey);
}


@end


#pragma clang diagnostic pop