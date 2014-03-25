//
//  CBJoystick.m
//  CBJoystick
//
//  Created by CocoaBob on 25/03/14.
//  Copyright (c) 2014 CocoaBob. All rights reserved.
//

#import "CBJoystick.h"

@interface CBJoystick () {
    CGPoint deltaFactor;
    UIImageView *thumbImageView;
    UIImageView *bgImageView;
}

@property (nonatomic) NSTimer *timer;

@end

@implementation CBJoystick

#pragma mark - Life Cycle

- (void)awakeFromNib {
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - Initialization

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    
    deltaFactor = CGPointMake(0, 0);

    bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:bgImageView];

    thumbImageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, self.bounds.size.width/4, self.bounds.size.height/4)];
    [self addSubview:thumbImageView];

    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRHandler:)];
    [panGR setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panGR];
}

- (void)setThumbImage:(UIImage *)thumbImage andBGImage:(UIImage *)bgImage {
    thumbImageView.image = thumbImage;
    bgImageView.image = bgImage;
}

#pragma mark - Gesture Handler

- (void)panGRHandler:(UIPanGestureRecognizer *)panGR {
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            CGPoint position = [panGR locationInView:self];
            CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            CGFloat radius = self.bounds.size.width / 2;

            CGFloat deltaX = position.x - center.x;
            CGFloat deltaY = position.y - center.y;
            if (powf(deltaX, 2) + powf(deltaY, 2) > powf(radius, 2)) {
                CGFloat angle = atan(deltaY / deltaX);
                CGPoint oldOffset = CGPointMake(deltaX, deltaY);
                CGPoint newOffset = CGPointMake(radius * cos(angle), radius * sin(angle));
                if (SGN(newOffset.x) != SGN(oldOffset.x))
                    newOffset.x = -newOffset.x;
                if (SGN(newOffset.y) != SGN(oldOffset.y))
                    newOffset.y = -newOffset.y;
                position = CGPointMake(center.x + newOffset.x, center.y + newOffset.y);
            }

            thumbImageView.center = position;

            deltaFactor.x = (position.x - center.x)/ radius;
            deltaFactor.y = (center.y - position.y)/ radius;

            [self beginUpdating];
        }
            break;
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
        {
            CGPoint selfCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            thumbImageView.center = selfCenter;

            deltaFactor = CGPointZero;

            [self stopUpdating];
        }
            break;
    }
}

#pragma mark - Updates

- (void)timerHandler {
    [self.delegate joystick:self didUpdate:deltaFactor];
}

- (void)beginUpdating {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.016667 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
    }
}

- (void)stopUpdating {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
