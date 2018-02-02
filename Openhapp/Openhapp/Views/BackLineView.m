//
//  BackLineView.m
//  Openhapp
//
//  Created by Jesse on 16/2/26.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "BackLineView.h"

@interface BackLineView ()
@property (nonatomic,assign) CGFloat height;
@end

@implementation BackLineView


-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.bounds = frame;
        self.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        self.height = frame.size.height / 13;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1;
    [[UIColor grayColor] setStroke];
    
    [path moveToPoint:CGPointMake(20, 1)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - 20, 1)];
    [path moveToPoint:CGPointMake(20, self.height + 1)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - 20, self.height + 1)];
    [path moveToPoint:CGPointMake(20, self.height * 2 + 1)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - 20, self.height * 2 + 1)];
    [path moveToPoint:CGPointMake(20, self.height * 3 + 1)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - 20, self.height * 3 + 1)];
    [path moveToPoint:CGPointMake(20, self.height * 4 + 1)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - 20, self.height * 4 + 1)];
    [path moveToPoint:CGPointMake(20, self.height * 5 + 1)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - 20, self.height * 5 + 1)];
    [path moveToPoint:CGPointMake(20, self.height * 6 + 1)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - 20, self.height * 6 + 1)];
    
    [path stroke];
}

-(UIView*)makeBackgroundLineView
{
    self.lineHeight = self.height;
    self.bottomY = self.height * 6 + 1;
    return self;
}


@end
