//
//  BackLineView.h
//  Openhapp
//
//  Created by Jesse on 16/2/26.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackLineView : UIView

@property (nonatomic,assign) CGFloat lineHeight;
@property (nonatomic,assign) CGFloat bottomY;

-(UIView*)makeBackgroundLineView;

@end
