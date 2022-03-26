
#import <UIKit/UIKit.h>
#import "RUAAdjusterView.h"
#import "LocationIndicatorImageView.h"
#import "DisplayView.h"

@interface ViewController : UIViewController <LocationIndicatorImageViewDataSource,DisplayViewDataSource,LocationIndicatorImageViewDelegate,RUAAdjusterViewDelegate> {
    float priorX;
    float priorY;
    float currentTemp;
    float currentPressure;
    float currentSpecVolume;
    float currentIntEnergy;
    float currentEnthalpy;
    float currentEntropy;
    float currentQuality;

    // Signifies that a touch has been registered AT ANY POINT in the past
    // It will not reset to false when switching charts
    BOOL touchHasRegistered;

    BOOL allowQualityScrubbing;
    NSString *currentRegion;
}

@property (strong, nonatomic) UIButton *buttonView_0;
@property (strong, nonatomic) UIButton *buttonView_1;
@property (strong, nonatomic) UIButton *buttonView_2;

@end
