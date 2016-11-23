//
//  MLDragCardView.m
//  MLCardAnimation
//
//  Created by maweilong-PC on 2016/11/22.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MLDragCardView.h"
#import "CardHeader.h"

#define ACTION_MARGIN_RIGHT lengthFit(150)
#define ACTION_MARGIN_LEFT lengthFit(150)
#define ACTION_VELOCITY 400
#define SCALE_STRENGTH 4
#define SCALE_MAX .93
#define ROTATION_MAX 1
#define ROTATION_STRENGTH lengthFit(414)

#define BUTTON_WIDTH lengthFit(40)

@interface MLDragCardView (){
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

@property (strong,nonatomic) UILabel *nameLabel;

@end

@implementation MLDragCardView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius  = 4;
        self.layer.shadowRadius  = 3;//阴影半径，默认3
        self.layer.shadowOpacity = 0.2; //阴影透明度，默认0
        //hadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.layer.shadowOffset  = CGSizeMake(1, 1);
        self.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(beginDragged:)];
        [self addGestureRecognizer:self.panGesture];
        
        UIView *bgView  = [[UIView alloc] initWithFrame:self.bounds];
        bgView.layer.cornerRadius = 4;
        bgView.clipsToBounds      = YES;
        [self addSubview:bgView];
        
        self.headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        self.headerImageView.backgroundColor = [UIColor lightGrayColor];
        self.headerImageView.userInteractionEnabled = YES;
        [bgView addSubview:self.headerImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self.headerImageView addGestureRecognizer:tap];
        
        
        
        
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.frame.size.width+10, self.frame.size.width - 40, 20)];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [bgView addSubview:self.nameLabel];
        
        UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.frame.size.width +30, self.frame.size.width - 40, 20)];
        alertLabel.font = [UIFont systemFontOfSize:12];
        alertLabel.textColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1];
        alertLabel.text = @"其它，10km";
        [bgView addSubview:alertLabel];
        
        self.layer.allowsEdgeAntialiasing                 = YES;
        bgView.layer.allowsEdgeAntialiasing               = YES;
        self.headerImageView.layer.allowsEdgeAntialiasing = YES;
    }
    return self;
}
#pragma mark - 填充数据
-(void)layoutSubviews {
    self.nameLabel.text = [NSString stringWithFormat:@"郑爽 %@号",self.infoDict[@"number"]];
    self.headerImageView.image = [UIImage imageNamed:self.infoDict[@"image"]];
}
- (void)tapGesture:(UITapGestureRecognizer *)sender{
    if (!self.canPan) {
        return;
    }
    NSLog(@"tap");
}

#pragma mark - 拖动手势
- (void)beginDragged:(UIPanGestureRecognizer *)gesture{
    if (!self.canPan) {
        return;
    }
    xFromCenter = [gesture translationInView:self].x;
    yFromCenter = [gesture translationInView:self].y;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX);
            CGFloat rotationAngel = (CGFloat)(ROTAION_ANGLE*rotationStrength);
            CGFloat scale = MAX(1 - fabs(rotationStrength)/SCALE_STRENGTH, SCALE_MAX);
            self.center = CGPointMake(self.originalCenter.x+xFromCenter, self.originalCenter.y+yFromCenter);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            self.transform = scaleTransform;
            [self updateOverLay:xFromCenter];
            
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self followUpActionWithDistance:xFromCenter andVelocity:[gesture velocityInView:self.superview]];
        }
            break;
        default:
            break;
    }
    
}
#pragma mark ----------- 滑动时候，按钮变大
- (void)updateOverLay:(CGFloat)distance {
    //滑动后更改其他卡片的位置
    [self.delegate moveCards:distance];
    //[self.delegate adjustOtherCards];
}

#pragma mark - 滑动后续动作判断
- (void)followUpActionWithDistance:(CGFloat)distance andVelocity:(CGPoint)velocity{
    if (xFromCenter>0 && (distance > ACTION_MARGIN_RIGHT || velocity.x >ACTION_VELOCITY)) {
        [self rightAction:velocity];
    }else if (xFromCenter<0 && (distance < -ACTION_MARGIN_RIGHT || velocity.x < -ACTION_VELOCITY)){
        [self leftAction:velocity];
    }else{
        //回到原点
        [UIView animateWithDuration:RESET_ANIMATION_TIME animations:^{
            self.center              = self.originalCenter;
            self.transform           = CGAffineTransformMakeRotation(0);
            self.yesButton.transform = CGAffineTransformMakeScale(1, 1);
            self.noButton.transform  = CGAffineTransformMakeScale(1, 1);
        }];
        [self.delegate moveBackCards];
    }
}
//向右滑动
- (void)rightAction:(CGPoint)velocity{
    CGFloat distanceX = [UIScreen mainScreen].bounds.size.width + CARD_WIDTH +self.originalCenter.x;//横向移动距离
    CGFloat distanceY = distanceX * yFromCenter/xFromCenter;//纵向移动距
    CGPoint finishPoint = CGPointMake(self.originalCenter.x +distanceX, self.originalCenter.y +distanceY);//
    CGFloat vel = sqrtf(pow(velocity.x, 2)+pow(velocity.y, 2));//滑动手势横纵合速度
    CGFloat displace = sqrt(pow(distanceX-xFromCenter, 2)+pow(distanceY-yFromCenter, 2));//需要动画完成的剩下的距离
    CGFloat duration = fabs(displace/vel);//动画的时间
    if (duration>0.6) {
        duration=0.6;
    }else if (duration<0.3){
        duration=0.3;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.yesButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.center = finishPoint;
        self.transform = CGAffineTransformMakeRotation(ROTAION_ANGLE);
    }completion:^(BOOL complete) {
        self.yesButton.transform = CGAffineTransformMakeScale(1, 1);
        [self.delegate swipCard:self Direction:YES];
    }];
    [self.delegate adjustOtherCards];//剩余卡片重新布局
    
}
//向左滑动
- (void)leftAction:(CGPoint)velocity{
    //横向移动距离
    CGFloat distanceX = -CARD_WIDTH - self.originalPoint.x;
    //纵向移动距离
    CGFloat distanceY = distanceX*yFromCenter/xFromCenter;
    //目标center点
    CGPoint finishPoint = CGPointMake(self.originalPoint.x+distanceX, self.originalPoint.y+distanceY);
    
    CGFloat vel = sqrtf(pow(velocity.x, 2) + pow(velocity.y, 2));
    CGFloat displace = sqrtf(pow(distanceX - xFromCenter, 2) + pow(distanceY - yFromCenter, 2));
    
    CGFloat duration = fabs(displace/vel);
    if (duration>0.6) {
        duration = 0.6;
    }else if(duration < 0.3) {
        duration = 0.3;
    }
    [UIView animateWithDuration:duration
                     animations:^{
                         self.noButton.transform=CGAffineTransformMakeScale(1.5, 1.5);
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-ROTAION_ANGLE);
                     } completion:^(BOOL finished) {
                         self.noButton.transform=CGAffineTransformMakeScale(1, 1);
                         [self.delegate swipCard:self Direction:NO];
                     }];
    
    [self.delegate adjustOtherCards];
}

- (void)rightButtonClickAction{

}

- (void)leftButtonClickAction{

}
@end
