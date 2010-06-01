#import "NSString+EscapingUtils.h"

@implementation NSString (EscapingUtils)
- (NSString *)stringByPreparingForURL {
	NSString *escapedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																				  (CFStringRef)self,
																				  NULL,
																				  (CFStringRef)@":/?=,!$&'()*+;[]@#",
																				  CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	
	return [escapedString autorelease];
}
@end
