//
//  KCNameInputViewController.m
//  
//
//  Created by  on 13/1/28.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "NameTVC.h"
#import "KCTools.h"

@interface NameTVC ()
{
    UITextField *_textField;
    IBOutlet UITableViewCell *_cell;
}


@end

@implementation NameTVC

#pragma mark - viewcontroller's life cycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the background of tableview
    UIImage *imgTableViewBackground = [UIImage imageNamed:@"123"];
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:imgTableViewBackground];
    
    
    // configure textfield
    
    if (!_textField) {
        _textField = [[UITextField alloc] init];
    }
    
    _textField.borderStyle = UITextBorderStyleNone;
    [_textField addTarget:self action:@selector(textField_EditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    _textField.backgroundColor = _cell.backgroundColor;
    _textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0]; // lightish blue color
//    _textField.textColor = DETAIL_LABEL_COLOR;
    
    CGRect frame = _cell.frame;
    frame.origin.x = 10;
    frame.size.height = 25;
    frame.size.width = 280;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        frame.origin.y = 10;
        //frame.size.height = 50;
    }
    _textField.frame = frame;
    
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [_cell.contentView addSubview:_textField];
    
    // to show keyboard
    [_textField becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        // back button was pressed.
        // We know this is true because self is no longer in the navigation stack.
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setName:(NSString *)name
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
    }
    
    _textField.text = name;
}

-(NSString*) name
{
    return _textField ? _textField.text : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //    return _titleForHeader;
    
    return 20 ? @"  " : nil;
}

#pragma mark - IBActions
- (void)textField_EditingDidEndOnExit:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - others
- (void) setName:(NSString *)name delegate:(id<KCNameInputViewControllerDelegate>)delegate
{
    self.name = name;
    self.delegate = delegate;
}

@end
