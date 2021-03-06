//
//  MHTextField.m
//
//  Created by Mehfuz Hossain on 4/11/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import "MHTextField.h"
#import "CityListViewController.h"

@interface MHTextField()
{
    UITextField *_textField;
    BOOL _disabled;
}

@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic) BOOL hasScrollView;
@property (nonatomic) BOOL invalid;

@property (nonatomic, setter = setToolbarCommand:) BOOL isToolBarCommand;
@property (nonatomic, setter = setDoneCommand:) BOOL isDoneCommand;

@property (nonatomic , strong) UIBarButtonItem *previousBarButton;
@property (nonatomic , strong) UIBarButtonItem *nextBarButton;

@property (nonatomic, strong) NSMutableArray *textFields;

@end

@implementation MHTextField

@synthesize required;
@synthesize scrollView;
@synthesize toolbar;
@synthesize keyboardIsShown;
@synthesize keyboardSize;
@synthesize invalid;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self){
       
    }
    
    return self;
}

- (void) awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
   // [self setTintColor:[UIColor blackColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:self];
    
    toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.window.frame.size.width, 44);
    // set style
    [toolbar setBarStyle:UIBarStyleDefault];
    
    self.previousBarButton = [[UIBarButtonItem alloc] initWithTitle:@"前一项" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonIsClicked:)];
    self.nextBarButton = [[UIBarButtonItem alloc] initWithTitle:@"下一项" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonIsClicked:)];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonIsClicked:)];
    
    NSArray *barButtonItems = @[self.previousBarButton, self.nextBarButton, flexBarButton, doneBarButton];
    
    toolbar.items = barButtonItems;
    
    self.textFields = [[NSMutableArray alloc]init];
    
    [self markTextFieldsWithTagInView:self.superview];
}

- (void)markTextFieldsWithTagInView:(UIView*)view
{
    int index = 0;
    if ([self.textFields count] == 0){
        for(UIView *subView in view.subviews){
            if ([subView isKindOfClass:[MHTextField class]]){
                MHTextField *textField = (MHTextField*)subView;
                textField.tag = index;
                [self.textFields addObject:textField];
                index++;
                
            }
        }
    }
}

- (void) doneButtonIsClicked:(id)sender
{
    if ([_textFieldDelegate respondsToSelector:@selector(editComplete)]) {
        //调用指定的协议方法
        [_textFieldDelegate editComplete];
    }
    if (_isGendersField) {
        
        if (!gendersChangeFlag) {
       
            NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
            
            if ([def boolForKey:@"userGenders"]){
                
                [_textField setText:@"男"];
                
            }else{
                [_textField setText:@"女"];
            }
            
        }
        
    }
    [self setDoneCommand:YES];
    [self resignFirstResponder];
    [self setToolbarCommand:YES];
   
}

-(void) keyboardDidShow:(NSNotification *) notification
{
    if (_textField == nil) return;
    if (keyboardIsShown) return;
    if (![_textField isKindOfClass:[MHTextField class]]) return;
    
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardSize = [aValue CGRectValue].size;
    
    [self scrollToField];
    
    self.keyboardIsShown = YES;
    
}

-(void) keyboardWillHide:(NSNotification *) notification
{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (_isDoneCommand)
             [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
     }];
    
    keyboardIsShown = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:self];
}


- (void) nextButtonIsClicked:(id)sender
{
    NSInteger tagIndex = self.tag;
    MHTextField *textField =  [self.textFields objectAtIndex:++tagIndex];
    
    while (!textField.isEnabled && tagIndex < [self.textFields count])
        textField = [self.textFields objectAtIndex:++tagIndex];

    [self becomeActive:textField];
}

- (void) previousButtonIsClicked:(id)sender
{
    NSInteger tagIndex = self.tag;
    
    MHTextField *textField =  [self.textFields objectAtIndex:--tagIndex];
    
    while (!textField.isEnabled && tagIndex < [self.textFields count])
        textField = [self.textFields objectAtIndex:--tagIndex];
    
    [self becomeActive:textField];
}

- (void)becomeActive:(UITextField*)textField
{
    [self setToolbarCommand:YES];
    [self resignFirstResponder];
    [textField becomeFirstResponder];
}

- (void)setBarButtonNeedsDisplayAtTag:(int)tag
{
    BOOL previousBarButtonEnabled = NO;
    BOOL nexBarButtonEnabled =NO;

    for (int index = 0; index < [self.textFields count]; index++) {

        UITextField *textField = [self.textFields objectAtIndex:index];
    
        if (index < tag)
            previousBarButtonEnabled |= textField.isEnabled;
        else if (index > tag)
            nexBarButtonEnabled |= textField.isEnabled;
    }
    
    self.previousBarButton.enabled = previousBarButtonEnabled;
    self.nextBarButton.enabled = nexBarButtonEnabled;
}

- (void) selectInputView:(UITextField *)textField
{
  
    if (_isGendersField) {
        gendersChangeFlag=NO;
        
        pickerV=[[UIPickerView alloc]init];
        [pickerV setShowsSelectionIndicator:YES];
        pickerV.delegate=self;
        pickerV.dataSource=self;
        [textField setInputView:pickerV];
        
        NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
        
        if ([def boolForKey:@"userGenders"]){
        
            [pickerV selectRow:1 inComponent:0 animated:YES];
            
        }else{
        
            [pickerV selectRow:0 inComponent:0 animated:YES];
        }

    }
    
    if (_isDateField){
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        if (![textField.text isEqualToString:@""]){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [datePicker setDate:[NSDate date]];
            [datePicker setMaximumDate:[NSDate date]];
        }
        [textField setInputView:datePicker];
    }
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 2;
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)componen{
    NSString *str=nil;
    switch (row) {
        case 0:
            str=@"女";
            break;
        case 1:
            str=@"男";
            break;
        default:
            break;
    }
    return str;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    gendersChangeFlag=YES;
    NSString *str=nil;
    switch (row) {
        case 0:
            str=@"女";
            break;
        case 1:
            str=@"男";
            break;
        default:
            break;
    }
    [_textField setText:str];
    
    [self validate];
}
- (void)datePickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSDate *selectedDate = datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [
     dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    [_textField setText:[dateFormatter stringFromDate:selectedDate]];
    
    [self validate];
}

- (void)scrollToField
{
    CGRect textFieldRect = _textField.frame;
    
    CGRect aRect = self.window.bounds;
    
    aRect.origin.y = -scrollView.contentOffset.y;
    aRect.size.height -= keyboardSize.height + self.toolbar.frame.size.height + 22;
    
    CGPoint textRectBoundary = CGPointMake(textFieldRect.origin.x, textFieldRect.origin.y + textFieldRect.size.height);
   
    if (!CGRectContainsPoint(aRect, textRectBoundary) || scrollView.contentOffset.y > 0) {
        CGPoint scrollPoint = CGPointMake(0.0, self.superview.frame.origin.y + _textField.frame.origin.y + _textField.frame.size.height - aRect.size.height);
        
        if (scrollPoint.y < 0) scrollPoint.y = 0;
        
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (BOOL) validate
{
    NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
    
    if (required && [self.text isEqualToString:@""]){
        return YES;
    }
    else if (_isEmailField){
        NSString *emailRegEx =
        @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
        @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if (![emailTest evaluateWithObject:self.text]){
            self.text=@"";
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"邮箱格式错误，请重新输入!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            
            return YES;
        }
    }else if ([[def objectForKey:@"isUpdateCity"]isEqualToString:@"1"]){
    
        return YES;
        
    }

    return YES;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (!enabled)
        [self setBackgroundColor:[UIColor lightGrayColor]];
}

#pragma mark - UITextField notifications

- (void)textFieldDidBeginEditing:(NSNotification *) notification
{
    UITextField *textField = (UITextField*)[notification object];
    
    _textField = textField;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setBarButtonNeedsDisplayAtTag:textField.tag];
    
    if ([self.superview isKindOfClass:[UIScrollView class]] && self.scrollView == nil)
        self.scrollView = (UIScrollView*)self.superview;
    
    [self selectInputView:textField];
    [self setInputAccessoryView:toolbar];
    
    [self setDoneCommand:NO];
    [self setToolbarCommand:NO];
}

- (void)textFieldDidEndEditing:(NSNotification *) notification
{
    UITextField *textField = (UITextField*)[notification object];

    [self validate];
    
    _textField = nil;
    
    if (_isDateField && [textField.text isEqualToString:@""] && _isDoneCommand){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        
        [textField setText:[dateFormatter stringFromDate:[NSDate date]]];
    }
}

@end
