//
//  ViewController.m
//  HTTP_Test
//
//  Created by charlie on 2016/10/14.
//  Copyright © 2016年 MBP4001. All rights reserved.
//

#import "ViewController.h"
#import "TFHpple.h"
#import "ContentViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray * menuArray ;
    UITableView * mainTableView;
    int pageCount;
    NSString * lastUrlString;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (pageCount == 0) {
        pageCount = 1;
    }
    menuArray = [[ NSMutableArray alloc]init];
    self.view.backgroundColor= [ UIColor lightGrayColor];
    self.title = @"小說";
    mainTableView = [[ UITableView alloc]init];
    mainTableView.delegate=self;
    mainTableView.dataSource =self;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.bounces = NO;
    mainTableView.backgroundColor = [ UIColor blackColor];
    [self.view addSubview:mainTableView];
    [self setLayout];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavigationBar];
    [self loadData];
}
-(void)setLayout{
 
    NSDictionary * views = NSDictionaryOfVariableBindings(mainTableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]|" options:0 metrics:nil views:views]];
}
-(void)setNavigationBar{

    UIBarButtonItem * rightButton = [[ UIBarButtonItem alloc]initWithTitle:@"下一頁" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc]initWithTitle:@"上一頁" style:UIBarButtonItemStylePlain target:self action:@selector(pre)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
}
-(void)loadData{
    [menuArray removeAllObjects];
    NSString *urlString = [ NSString stringWithFormat:@"http://ck101.com/forum-237-%d.html",pageCount];
    
    if ([urlString isEqualToString:lastUrlString]) {
        return;
    }
    
    NSData * data = [ NSData  dataWithContentsOfURL:[NSURL URLWithString:urlString] options:0 error:nil];
    
    TFHpple * xpathParser = [[TFHpple alloc]initWithHTMLData:data];
    NSArray * nodes = [ xpathParser searchWithXPathQuery:@"//tbody[@class ='threadrow']/tr/td/div[@class ='l_sPic']/a"];
    NSArray * lastArray = [xpathParser searchWithXPathQuery:@"//a[@class = 'last']"];
    for (TFHppleElement * element in nodes) {
        NSMutableDictionary * dic = [[ NSMutableDictionary alloc]init];
        NSString * name = [element.attributes objectForKey:@"title"];
        NSString * url = [element.attributes objectForKey:@"href"];
        NSLog(@"%@",name);
        NSLog(@"%@",url);
        [dic setObject:name forKey:@"name"];
        [dic setObject:url forKey:@"url"];
        [menuArray addObject:dic];
    }
    
    for (TFHppleElement * last in lastArray) {
        lastUrlString = [last.attributes objectForKey:@"href"];
        NSLog(@"%@",lastUrlString);
    }
    
    [mainTableView reloadData];
    [mainTableView setContentOffset:CGPointMake(0.0f, -mainTableView.contentInset.top) animated:NO];
}
-(void)next{
    pageCount ++ ;
    [self loadData];
}
-(void)pre{
    pageCount -- ;
    if (pageCount < 1 ) {
        pageCount = 1;
        return;
    }
    [self loadData];
}

#pragma mark - tableView 
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return menuArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"cell";
    UITableViewCell * cell  = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text = [(NSDictionary*)[menuArray objectAtIndex:indexPath.row]objectForKey:@"name"];
    cell.textLabel.textColor = [ UIColor whiteColor];
    cell.backgroundColor = [ UIColor blackColor];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString * url = [(NSDictionary*)[menuArray objectAtIndex:indexPath.row]objectForKey:@"url"];
    NSString * name = [(NSDictionary*)[menuArray objectAtIndex:indexPath.row]objectForKey:@"name"];
    NSLog(@"%@",url);
    ContentViewController * contentViewController = [[ContentViewController alloc]initWithUrl:url andName:name];
    [self.navigationController pushViewController:contentViewController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
