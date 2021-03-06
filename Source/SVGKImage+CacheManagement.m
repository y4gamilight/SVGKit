#import "SVGKImage.h"
#import "SVGKImage+CacheManagement.h"

static NSMutableDictionary<NSString*,SVGKImage*> *SVGCacheObject = nil;

@implementation SVGKImage (CacheManagement)
@dynamic nameUsedToInstantiate;

+ (void)clearSVGImageCache
{
	if (SVGCacheObject) {
		DDLogVerbose(@"[%@] Purging cache of %li SVGKImage's...", self, (long)[SVGCacheObject count] );
		[SVGCacheObject removeAllObjects];
	}else {
		DDLogInfo(@"[%@] Nothing to purge...", self);
	}
}

+ (void)removeSVGImageCacheNamed:(NSString*)theName
{
	if (SVGCacheObject) {
		[SVGCacheObject removeObjectForKey:theName];
	}
}

+ (NSArray*)storedCacheNames
{
	if (SVGCacheObject) {
		NSArray *allKeys = [[SVGCacheObject allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		return allKeys;
	} else {
		return @[];
	}
}

+ (void)setCacheEnabled:(BOOL)cacheEnabled
{
	if ([self isCacheEnabled] != cacheEnabled) {
		if (cacheEnabled) {
			[self enableCache];
		} else {
			[self disableCache];
		}
	}
}

+ (BOOL)isCacheEnabled
{
	BOOL isEnabled = (SVGCacheObject != nil);
	return isEnabled;
}

+ (void)enableCache
{
	if (!SVGCacheObject) {
		DDLogVerbose(@"[%@] INFO: Generating image cache.", self);

		SVGCacheObject = [[NSMutableDictionary alloc] init];
	};
}

+ (void)disableCache
{
	if (SVGCacheObject) {
		DDLogVerbose(@"[%@] INFO: Deleting image cache, %li images will be purged.", self, (long)[SVGCacheObject count]);
		
		SVGCacheObject = nil;
	}
}

+ (SVGKImage*)cachedImageForName:(NSString*)theName
{
	if (SVGCacheObject) {
		SVGKImage *retImage = SVGCacheObject[theName];
		return retImage;
	} else {
		return nil;
	}
}

@end

@implementation SVGKImage (CacheManagementPrivate)

+ (void)storeImageCache:(SVGKImage*)theImage forName:(NSString*)theName
{
	if (SVGCacheObject) {
		SVGCacheObject[theName] = theImage;
	}
}

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
+(void) didReceiveMemoryWarningNotification:(NSNotification*) notification
{
	if (SVGCacheObject) {
		DDLogWarn(@"[%@] Low-mem; purging cache of %li SVGKImage's...", self, (long)[SVGCacheObject count] );
		
		[SVGCacheObject removeAllObjects]; // once they leave the cache, if they are no longer referred to, they should automatically dealloc
	} else {
		DDLogWarn(@"[%@] Low-mem, but no cache to purge...", self);
	}
}
#endif

@end
