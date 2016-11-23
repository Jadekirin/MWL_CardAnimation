//
//  MLDragCardView.h
//  MLCardAnimation
//
//  Created by maweilong-PC on 2016/11/22.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROTAION_ANGLE M_PI/8
#define CLICK_ANIMATION_TIME 0.5
#define RESET_ANIMATION_TIME 0.3

@class MLDragCardView;
@protocol MLDragCardDelegate <NSObject>

-(void)swipCard:(MLDragCardView *)cardView Direction:(BOOL) isRight;

-(void)moveCards:(CGFloat)distance;

-(void)moveBackCards;

-(void)adjustOtherCards;


@end

@interface MLDragCardView : UIView

@property (nonatomic,weak)   id<MLDragCardDelegate> delegate;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (assign, nonatomic) CGAffineTransform originalTransform;
@property (assign, nonatomic) CGPoint originalPoint;
@property (assign, nonatomic) CGPoint originalCenter;
@property (assign, nonatomic) BOOL canPan;
@property (strong, nonatomic) NSDictionary *infoDict;
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UILabel *numLabel;
@property (strong, nonatomic) UIButton *noButton;
@property (strong, nonatomic) UIButton *yesButton;


- (void)leftButtonClickAction;
- (void)rightButtonClickAction;

@end
