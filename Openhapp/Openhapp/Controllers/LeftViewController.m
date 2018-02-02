//
//  LeftViewController.m
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
#import "DataTool.h"
#import "DeviceManageViewController.h"
#import "UserViewController.h"
#import "HelpViewController.h"
#import "SetViewController.h"
#import "AboutViewController.h"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate>

//设置页面
@property (nonatomic,strong) UITableView *setTableView;
//设置项目
@property (nonatomic,strong) NSArray *setItems;
//设置图标
@property (nonatomic,strong) NSArray *setImages;
//增大高度
@property (nonatomic,assign) CGFloat addHeight;

@end

@implementation LeftViewController

-(NSArray*)setItems
{
    if (!_setItems)
    {
        _setItems = [DataTool getSetItems];
    }
    return _setItems;
}

-(NSArray*)setImages
{
    if (!_setImages)
    {
        _setImages = [DataTool getSetImages];
    }
    return _setImages;
}

-(CGFloat)addHeight
{
    if (!_addHeight)
    {
        _addHeight = (self.view.bounds.size.height - 480) / 10;//基准差值
    }
    return _addHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    leftImageView.image = [UIImage imageNamed:@"leftbackiamge"];
    [self.view addSubview:leftImageView];
    
    self.setTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.setTableView.delegate = self;
    self.setTableView.dataSource = self;
    self.setTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.setTableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
    self.setTableView.scrollEnabled = NO;
    self.setTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.setTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SetCell"];
        cell.textLabel.text = [DataTool getAccount];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SetCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *setIcon = self.setImages[indexPath.row - 1];
        UIImageView *setImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:setIcon]];
        setImageView.frame = CGRectMake((40 + self.addHeight) / 4, (40 + self.addHeight) / 4, (40 + self.addHeight) / 2, (40 + self.addHeight) / 2);
        [cell.contentView addSubview:setImageView];
        UILabel *setLabel = [[UILabel alloc] initWithFrame:CGRectMake((40 + self.addHeight) * 3 / 2, (40 + self.addHeight) / 4, (40 + self.addHeight) * 2, (40 + self.addHeight) / 2)];
        setLabel.text = self.setItems[indexPath.row - 1];
        setLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:setLabel];
        return cell;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [[UIScreen mainScreen] bounds].size.height / 8)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drawer_logo"]];
        imageView.frame = CGRectMake(0, 0, headView.bounds.size.width - 40, (headView.bounds.size.width - 40) * 254 / 1089);
        imageView.center = headView.center;
        [headView addSubview:imageView];
        return headView;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0)
    {
        AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [mainAppDelegate.leftSlideVC closeLeftView];
        switch (indexPath.row)
        {
            case 1:
                [mainAppDelegate.leftSlideVC dismissViewControllerAnimated:YES completion:nil];
                [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
                break;
                
            case 2:
                [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
                break;
                
            case 3:
                [mainAppDelegate.mainNVC pushViewController:[DeviceManageViewController new] animated:YES];
                break;
                
            case 4:
                [mainAppDelegate.mainNVC pushViewController:[UserViewController new] animated:YES];
                break;
                
            case 5:
                [mainAppDelegate.mainNVC pushViewController:[HelpViewController new] animated:YES];
                break;
                
            case 6:
                [mainAppDelegate.mainNVC pushViewController:[SetViewController new] animated:YES];
                break;
                
            case 7:
                [mainAppDelegate.mainNVC pushViewController:[AboutViewController new] animated:YES];
                break;
                
            default:
                break;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [[UIScreen mainScreen] bounds].size.height / 8;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40 + self.addHeight;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
