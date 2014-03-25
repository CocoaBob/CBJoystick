//
//  CBJoystick.h
//  CBJoystick
//
//  Created by CocoaBob on 25/03/14.
//  Copyright (c) 2014 CocoaBob. All rights reserved.
//

@protocol CBJoystickDelegate;

@interface CBJoystick : UIView
@property (nonatomic, weak) IBOutlet id<CBJoystickDelegate> delegate;
@property (nonatomic, assign) CGFloat idleAlpha;
@property (nonatomic, assign) CGFloat touchAlpha;
@property (nonatomic, assign) CGFloat inteval;
- (void)setThumbImage:(UIImage *)thumbImage andBGImage:(UIImage *)bgImage;
@end

@protocol CBJoystickDelegate <NSObject>
@optional
- (void)joystick:(CBJoystick *)aJoystick didBegin:(CGPoint)deltaFactor;
- (void)joystick:(CBJoystick *)aJoystick didUpdate:(CGPoint)deltaFactor;
@end