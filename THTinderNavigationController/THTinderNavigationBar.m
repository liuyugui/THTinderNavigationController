//
//  THTinderNavigationBar.m
//  THTinderNavigationControllerExample
//
//  Created by Tanguy Hélesbeux on 11/10/2014.
//  Copyright (c) 2014 Tanguy Hélesbeux. All rights reserved.
//

#import "THTinderNavigationBar.h"

#define kXHiPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define kXHLabelBaseTag 1000
#define WIDTH self.bounds.size.width
#define IMAGESIZE 38
#define Y_POSITION 24

static CGFloat MARGIN = 15.0;

@interface THTinderNavigationBar ()

@end

@implementation THTinderNavigationBar

#pragma mark - DataSource

- (void)reloadData {
    if (!self.itemViews.count) {
        return;
    }

    [self.itemViews enumerateObjectsUsingBlock:^(UIView <THTinderNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {

        CGFloat width = (WIDTH - MARGIN * 2);
        CGFloat step = (width / 2 - MARGIN) * idx;
        CGRect itemViewFrame = CGRectMake(step - MARGIN / 2, Y_POSITION, IMAGESIZE, IMAGESIZE);
        itemView.hidden = NO;
        itemView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        itemView.frame = itemViewFrame;

        if (self.currentPage + 1 == idx) {
            [self updateItemView:itemView withRatio:1.0];
        } else {
            [self updateItemView:itemView withRatio:0.0];
        }
    }];

    // Dirty hack
    [self setContentOffset:self.contentOffset];
}

- (void)tapGestureHandle:(UITapGestureRecognizer *)tapGesture {
    NSUInteger pageIndex = [self.itemViews indexOfObject:tapGesture.view];

    if (self.shouldChangePage) {
        if (self.shouldChangePage(pageIndex)) {
            [self.navigationController setCurrentPage:pageIndex animated:YES];
        }
    } else {
        [self.navigationController setCurrentPage:pageIndex animated:YES];
    }
}

- (void)swipeGestureHandle:(UISwipeGestureRecognizer *)swipeGesture {

    NSUInteger pageIndex = [self.navigationController getCurrentPageIndex];
    if (self.shouldChangePage) {
        if (self.shouldChangePage(pageIndex)) {
            NSUInteger nextPageIndex = pageIndex;
            if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
                if (nextPageIndex > 0 && nextPageIndex <= self.itemViews.count - 1) {
                    nextPageIndex--;
                }
            } else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
                if (nextPageIndex >= 0 && nextPageIndex < self.itemViews.count - 1) {
                    nextPageIndex++;
                }
            }
            [self.navigationController setCurrentPage:nextPageIndex animated:YES];
        }
    } else {
        NSUInteger nextPageIndex = pageIndex;
        if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
            if (nextPageIndex > 0 && nextPageIndex <= self.itemViews.count - 1) {
                nextPageIndex--;
            }
        } else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
            if (nextPageIndex >= 0 && nextPageIndex < self.itemViews.count - 1) {
                nextPageIndex++;
            }
        }
        [self.navigationController setCurrentPage:nextPageIndex animated:YES];
    }
}

#pragma mark - Other

- (void)updateItemView:(UIView <THTinderNavigationBarItem> *)itemView withRatio:(CGFloat)ratio {
    if ([itemView respondsToSelector:@selector(updateViewWithRatio:)]) {
        [itemView updateViewWithRatio:ratio];
    }
}

#pragma mark - Properties

- (void)setContentOffset:(CGPoint)contentOffset {
    _contentOffset = contentOffset;

    CGFloat xOffset = contentOffset.x;

    CGFloat normalWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);

    [self.itemViews enumerateObjectsUsingBlock:^(UIView <THTinderNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {

        CGFloat width = (WIDTH - MARGIN * 2);
        CGFloat step = (width / 2 - IMAGESIZE / 2);// * idx;

        CGRect itemViewFrame = itemView.frame;
        itemViewFrame.origin.x = MARGIN + step * idx - xOffset / normalWidth * step + step;
        itemView.frame = itemViewFrame;

        CGFloat ratio;
        if (xOffset < normalWidth * idx) {
            ratio = (xOffset - normalWidth * (idx - 1)) / normalWidth;
        } else {
            ratio = 1 - ((xOffset - normalWidth * idx) / normalWidth);
        }

        [self updateItemView:itemView withRatio:ratio];
    }];
}

- (void)setItemViews:(NSArray *)itemViews {
    if (itemViews) {

        [self.itemViews enumerateObjectsUsingBlock:^(UIView <THTinderNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {
            [itemView removeFromSuperview];
        }];

        [itemViews enumerateObjectsUsingBlock:^(UIView <THTinderNavigationBarItem> *itemView, NSUInteger idx, BOOL *stop) {
            itemView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
            [itemView addGestureRecognizer:tapGesture];
            [self addSubview:itemView];
        }];
    }

    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandle:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandle:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;

    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    [self addGestureRecognizer:swipeRightGestureRecognizer];

    _itemViews = itemViews;
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

@end

