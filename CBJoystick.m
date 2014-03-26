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
    BOOL isTouching;
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
    _alphaIdle = 0.5;
    _alphaTouch = 0.75;
    _inteval = 0.05;
    _thumbMargin = self.frame.size.width * 0.1;

    self.alpha = _alphaIdle;
    self.backgroundColor = [UIColor clearColor];

    deltaFactor = CGPointMake(0, 0);

    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRHandler:)];
    [panGR setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panGR];
}

#pragma mark - Properties

- (void)setThumbImage:(UIImage *)thumbImage andBGImage:(UIImage *)bgImage {
    if (bgImageView)
        [bgImageView removeFromSuperview];
    if (thumbImageView)
        [thumbImageView removeFromSuperview];

    bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    bgImageView.image = bgImage;
    [self addSubview:bgImageView];

    CGFloat thumbImageViewSize = floor(self.bounds.size.width * thumbImage.size.width / bgImage.size.width);
    thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbImageViewSize, thumbImageViewSize)];
    thumbImageView.image = thumbImage;
    [self addSubview:thumbImageView];

    thumbImageView.center = bgImageView.center;
}

- (void)setInteval:(CGFloat)newValue {
    _inteval = newValue;
    if (_timer) {
        [self stopUpdating];
        [self beginUpdating];
    }
}

- (void)setAlphaIdle:(CGFloat)newValue {
    _alphaIdle = newValue;
    self.alpha = isTouching?_alphaTouch:_alphaIdle;
}

- (void)setAlphaTouch:(CGFloat)newValue {
    _alphaTouch = newValue;
    self.alpha = isTouching?_alphaTouch:_alphaIdle;
}

#pragma mark - Gesture Handler

- (void)panGRHandler:(UIPanGestureRecognizer *)panGR {
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            isTouching = YES;
            self.alpha = _alphaTouch;

            CGPoint position = [panGR locationInView:self];
            CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            CGFloat radius = self.bounds.size.width * 0.5 - _thumbMargin;

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

            if (panGR.state == UIGestureRecognizerStateBegan) {
                if ([self.delegate respondsToSelector:@selector(joystick:didBegin:)]) {
                    [self.delegate joystick:self didBegin:deltaFactor];
                }
            }
            [self beginUpdating];
        }
            break;
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
        {
            isTouching = NO;
            self.alpha = _alphaIdle;

            CGPoint selfCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            thumbImageView.center = selfCenter;

            [self stopUpdating];

            if ([self.delegate respondsToSelector:@selector(joystick:didEnd:)]) {
                [self.delegate joystick:self didEnd:deltaFactor];
            }

            deltaFactor = CGPointZero;
        }
            break;
    }
}

#pragma mark - Updates

- (void)timerHandler {
    if ([self.delegate respondsToSelector:@selector(joystick:didUpdate:)]) {
        [self.delegate joystick:self didUpdate:deltaFactor];
    }
}

- (void)beginUpdating {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_inteval target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
    }
}

- (void)stopUpdating {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
