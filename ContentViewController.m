//
//  ContentViewController.m
//  HTTP_Test
//
//  Created by charlie on 2016/10/14.
//  Copyright © 2016年 MBP4001. All rights reserved.
//

#import "ContentViewController.h"
#import "TFHpple.h"
#import <QuartzCore/QuartzCore.h>
@interface ContentViewController ()<UITextViewDelegate>{
    NSString * urlString;
    NSMutableArray * textArray;
    UITextView * textView;
    NSString * nextUrlString;
    NSString * preUrlString;
    NSString * lastUrlString;
    
    UIButton * nextButton;
    UIButton * preButton;
    UIButton * firstButton;
    UIView * bottomView;
}

@end

@implementation ContentViewController

-(instancetype)initWithUrl:(NSString *)url andName:(NSString *)name{
    self = [super init];
    if (self) {
        NSArray * nameArray = [name componentsSeparatedByString:@"作者"];
        self.title=[nameArray firstObject];
        urlString = url;
        textArray = [[ NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setView];
    [self setlayout];
    [self loadData:urlString];
}
-(void)setView{
    
    textView = [[ UITextView alloc]init];
    textView.delegate= self;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [textView setEditable:NO];
    textView.showsHorizontalScrollIndicator = NO;
    textView.clipsToBounds = YES;
    textView.font = [UIFont boldSystemFontOfSize:18.0];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.backgroundColor = [ UIColor blackColor];
    textView.textColor = [ UIColor whiteColor];
    textView.scrollEnabled = YES;
    
    [self.view addSubview:textView];

    nextButton = [[ UIButton alloc]init];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [nextButton setTitle:@"下一頁" forState:UIControlStateNormal];
    [nextButton setBackgroundColor:[UIColor grayColor]];
    [nextButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    preButton = [[ UIButton alloc]init];
    preButton.translatesAutoresizingMaskIntoConstraints = NO;
    [preButton setTitle:@"上一頁" forState:UIControlStateNormal];
    [preButton setBackgroundColor:[UIColor grayColor]];
    [preButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    firstButton = [[UIButton alloc]init];
    firstButton.translatesAutoresizingMaskIntoConstraints = NO;
    [firstButton setTitle:@"回首頁" forState:UIControlStateNormal];
    [firstButton setBackgroundColor:[UIColor grayColor]];
    [firstButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    bottomView = [[ UIView alloc]init];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomView.backgroundColor = [UIColor lightGrayColor];
    bottomView.layer.borderWidth = 1;
    bottomView.layer.borderColor = [ UIColor brownColor].CGColor;
    
    [bottomView addSubview:nextButton];
    [bottomView addSubview:preButton];
    [bottomView addSubview:firstButton];
    [self.view addSubview:bottomView];
    
    NSDictionary * views = NSDictionaryOfVariableBindings(preButton,nextButton,firstButton);
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[preButton][firstButton(preButton)][nextButton(preButton)]|" options:0 metrics:nil views:views]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[preButton]|" options:0 metrics:nil views:views]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[firstButton]|" options:0 metrics:nil views:views]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nextButton]|" options:0 metrics:nil views:views]];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
-(void)setlayout{
    NSDictionary * views = NSDictionaryOfVariableBindings(textView,bottomView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView][bottomView(40)]|" options:0 metrics:nil views:views]];
}
-(void)loadData:(NSString*)url{
    
    [textArray removeAllObjects];

    NSData * data = [ NSData  dataWithContentsOfURL:[NSURL URLWithString:url] options:0 error:nil];
    TFHpple * xpathParser = [[TFHpple alloc]initWithHTMLData:data];
    NSArray * nodes = [ xpathParser searchWithXPathQuery:@"//table[@cellspacing ='0']/tr/td[@class ='t_f']"];

    NSArray * nextPage = [xpathParser searchWithXPathQuery:@"//a[@class = 'nxt']"];
    NSArray * prePage = [xpathParser searchWithXPathQuery:@"//a[@class ='prev']"];
    NSArray * lastPage = [xpathParser searchWithXPathQuery:@"//a[@class = 'last']"];
    for (int i =0 ; i < nodes.count; i++) {
        if (i != 0) {
        TFHppleElement * element = [ nodes objectAtIndex:i];
        [textArray addObject:element.content];

        }
    }
//    for (TFHppleElement * element in nodes) {
//        NSLog(@"%@",element.content);
//        [textArray addObject:element.content];
//    }
    //應該有2個 最上一個 最下一個 不過都一樣
    for (TFHppleElement * element in nextPage) {
        nextUrlString = [element objectForKey:@"href"];
        NSLog(@"%@",nextUrlString);
    }
    
    for (TFHppleElement * element in prePage) {
        preUrlString = [element objectForKey:@"href"];
        NSLog(@"%@",preUrlString);
    }
    
    for (TFHppleElement *element in lastPage) {
        lastUrlString = [element objectForKey:@"href"];
        NSLog(@"%@",lastUrlString);
    }

    [self reloadText];
}

-(void)reloadText{
    NSString * textString;
    for (int i = 0 ; i < textArray.count; i++) {
        NSString * string = [ textArray objectAtIndex:i];
        if (i == 0) {
            textString = string;
            dispatch_async(dispatch_get_main_queue(), ^{
                textView.text = textString;
            });
        }else{
            textString = [NSString stringWithFormat:@"%@\n%@",textString,string];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        textView.text = textString;
    });
    

    [textView setContentOffset:CGPointMake(0, -textView.contentInset.top)];
}


-(void)buttonClick:(UIButton*)btn{

    if ([btn isEqual:preButton]) {
        if (preUrlString == nil) {
            return;
        }
        [self loadData:preUrlString];
        
    }else if([btn isEqual:nextButton]){
        if ([nextUrlString isEqualToString:lastUrlString]) {
            return;
        }else{
            [self loadData:nextUrlString];
        }
    }else if ([btn isEqual:firstButton]){
        [self loadData:urlString];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
