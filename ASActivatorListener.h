#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>

typedef void (^ASActivatorListenerEventHandler) (LAEvent *event, BOOL abortEventCalled);
 
@interface ASActivatorListener : NSObject <LAListener>
@property ASActivatorListenerEventHandler eventHandler;
+(instancetype)sharedInstance;
- (void)loadWithEventHandler:(ASActivatorListenerEventHandler)handler;
-(void)load;
- (void)unload;
@end