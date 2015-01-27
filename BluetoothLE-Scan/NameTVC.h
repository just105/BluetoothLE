//
//  KCNameInputViewController.h
//
//
//  Created by  on 13/1/28.
//  Copyright (c) 2013年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@class NameTVC;

@protocol KCNameInputViewControllerDelegate <NSObject>

@required

@end

@interface NameTVC : UITableViewController

@property (nonatomic, strong) id<KCNameInputViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *name;

- (void) setName:(NSString *)name delegate:(id<KCNameInputViewControllerDelegate>)delegate;

@end
