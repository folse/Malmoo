//
//  PhotoCollectionController.m
//  Malmoo
//
//  Created by Jennifer on 8/11/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSPhotoCollectionController.h"
#import "TSPhotoCollectionViewCell.h"
#import "TSPhotoGalleryController.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface TSPhotoCollectionController ()
{
    NSMutableArray *photos;
    NSMutableArray *photoUrlArray;
    NSString *selectedPhotoUrl;
}

@end

@implementation TSPhotoCollectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[FSUtilSettings createImageWithColor:APP_COLOR] forBarMetrics:UIBarMetricsDefault];
    
    //[MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    photoUrlArray = [NSMutableArray new];
    
    [self getPhotos];
}

-(void)getPhotos
{
    PFRelation *relation = [_place.parseObject relationForKey:@"photos"];
    PFQuery *productPhotoQuery = [relation query];
    //[productPhotoQuery whereKey:@"product" equalTo:@"true"];
    [productPhotoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            photos = [NSMutableArray arrayWithCapacity:[objects count]];
            
            for (PFObject *photoObject in objects) {
                
                if (photoObject[@"url"] != nil) {
                    
                    [photoUrlArray addObject:photoObject[@"url"]];
                    
                    MJPhoto *photo = [[MJPhoto alloc] init];
                    photo.url = [NSURL URLWithString:photoObject[@"url"]];
                    [photos addObject:photo];
                }
            }
            
            [self.collectionView reloadData];
            
        } else {
            
            s(error)
        }
    }];
    
    //    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    //    query.limit = 30;
    //    [query whereKey:@"place" equalTo:_place.parseObject];
    //    [query whereKey:@"category" equalTo:[PFObject objectWithoutDataWithClassName:@"PhotoCategory" objectId:@"kyal3eTN0P"]];
    //    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    //        if (!error) {
    //
    //            photos = [NSMutableArray arrayWithCapacity:[objects count]];
    //            for (PFObject *object in objects) {
    //
    //                if (object[@"url"] != nil) {
    //
    //                    [photoArray addObject:object[@"url"]];
    //
    //                    MJPhoto *photo = [[MJPhoto alloc] init];
    //                    photo.url = [NSURL URLWithString:object[@"url"]];
    //
    //                    [photos addObject:photo];
    //                }
    //            }
    //
    //            [self.collectionView reloadData];
    //        }
    //    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photoUrlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    TSPhotoCollectionViewCell *cell = (TSPhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:photoUrlArray[index]] placeholderImage:[UIImage imageNamed:@"default_shop_photo"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //selectedPhotoUrl = photoUrlArray[indexPath.row];
    //[self performSegueWithIdentifier:@"photoGalleryController" sender:self];
    s(photos)
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row;
    browser.photos = photos;
    [browser show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TSPhotoGalleryController *photoGalleryController =[segue destinationViewController];
    photoGalleryController.photoArray = [NSArray arrayWithObject:selectedPhotoUrl];
}

@end
