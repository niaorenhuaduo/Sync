#import "ViewController.h"
#import "CommentsViewController.h"
#import "DesignerNewsTableViewCell.h"
#import "DATAStack.h"
#import "APIClient.h"
#import "DATASource.h"
#import "Stories.h"

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) DATAStack *dataStack;
@property (nonatomic) DATASource *dataSource;
@property (nonatomic) NSMutableArray *arrayWithStories;

@end

@implementation ViewController

#pragma mark - Initializers

- (instancetype)initWithDataStack:(DATAStack *)dataStack
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) return nil;

    _dataStack = dataStack;

    return self;
}

#pragma mark - Getters

- (DATASource *)dataSource
{
    if (_dataSource) return _dataSource;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stories"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];

    _dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                           fetchRequest:request
                                         cellIdentifier:CellIdentifier
                                            mainContext:self.dataStack.mainContext];

    __weak __typeof__(self) weakSelf = self;

    _dataSource.configureCellBlock = ^(DesignerNewsTableViewCell *cell, Stories *story, NSIndexPath *indexPath) {
        weakSelf.arrayWithStories = [NSMutableArray arrayWithArray:[weakSelf.dataStack.mainContext executeFetchRequest:request error:nil]];
        [cell updateWithStory:story];
    };

    return _dataSource;
}

#pragma mark - TableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Stories *storySelected = self.arrayWithStories[indexPath.row];
    CommentsViewController *viewController = [CommentsViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController.story = storySelected;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Designer News";

    APIClient *client = [APIClient new];
    [client fetchStoriesUsingDataStack:self.dataStack];

    [self.tableView registerClass:[DesignerNewsTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.dataSource = self.dataSource;
    self.tableView.rowHeight = 65.0f;

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
