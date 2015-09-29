/**
 * Name: CrashReporter
 * Type: iOS application
 * Desc: iOS app for viewing the details of a crash, determining the possible
 *       cause of said crash, and reporting this information to the developer(s)
 *       responsible.
 *
 * Author: Lance Fetters (aka. ashikase)
 * License: GPL v3 (See LICENSE file for details)
 */

#import "BinaryImageCell.h"

#import "UIImage+CrashReporter.h"
#include "font-awesome.h"

#define kColorBinaryImageName      [UIColor blackColor]
#define kColorPackageName          [UIColor grayColor]
#define kColorPackageIdentifier    [UIColor grayColor]
#define kColorInstallDate          [UIColor grayColor]
#define kColorNewer                [UIColor lightGrayColor]
#define kColorRecent               [UIColor redColor]
#define kColorFromUnofficialSource [UIColor colorWithRed:0.8 green:0.2 blue:0.3 alpha:1.0]

static const UIEdgeInsets kContentInset = (UIEdgeInsets){6.0, 15.0, 6.0, 15.0};
static const CGFloat kFontSizeName = 18.0;
static const CGFloat kFontSizePackage = 12.0;
static const CGSize kMenuButtonImageSize = (CGSize){11.0, 15.0};

static UIImage *appleImage$ = nil;
static UIImage *debianImage$ = nil;
static UIImage *installDateImage$ = nil;

@implementation BinaryImageCell {
    UILabel *nameLabel_;
    UILabel *packageNameLabel_;
    UILabel *packageIdentifierLabel_;
    UILabel *packageInstallDateLabel_;
    UIImageView *packageIdentifierImageView_;
    UIImageView *packageInstallDateImageView_;
    UIView *topSeparatorView_;
    UIView *bottomSeparatorView_;
}

@synthesize newer = newer_;
@synthesize recent = recent_;
@synthesize fromUnofficialSource = fromUnofficialSource_;
@synthesize packageType = packageType_;

@dynamic showsTopSeparator;

#pragma mark - Creation & Destruction

+ (void)initialize {
    [super initialize];

    if (self == [BinaryImageCell self]) {
        // Create and cache icon font images.
        UIFont *imageFont = [UIFont fontWithName:@"FontAwesome" size:11.0];
        UIColor *imageColor = [UIColor blackColor];

        appleImage$ = [[UIImage imageWithText:@kFontAwesomeApple font:imageFont color:imageColor imageSize:kMenuButtonImageSize] retain];
        debianImage$ = [[UIImage imageWithText:@kFontAwesomeDropbox font:imageFont color:imageColor imageSize:kMenuButtonImageSize] retain];
        installDateImage$ = [[UIImage imageWithText:@kFontAwesomeClockO font:imageFont color:imageColor imageSize:kMenuButtonImageSize] retain];
    }
}

+ (CGFloat)heightForPackageRowCount:(NSUInteger)rowCount {
    // FIXME: The (+ x.0) values added to the font sizes are only valid for the
    //        current font sizes (18.0 and 12.0). Determine proper calculation.
    return kContentInset.top + kContentInset.bottom + (kFontSizeName + 4.0) + (kFontSizePackage + 3.0) * rowCount;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        UIView *contentView = [self contentView];

        UILabel *label;
        UIFont *font;

        font = [UIFont systemFontOfSize:kFontSizeName];
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [label setTextColor:kColorBinaryImageName];
        [label setFont:font];
        [contentView addSubview:label];
        nameLabel_ = label;

        font = [UIFont systemFontOfSize:kFontSizePackage];
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [label setTextColor:kColorPackageName];
        [label setFont:font];
        [contentView addSubview:label];
        packageNameLabel_ = label;

        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [label setTextColor:kColorPackageIdentifier];
        [label setFont:font];
        [contentView addSubview:label];
        packageIdentifierLabel_ = label;

        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [label setTextColor:kColorInstallDate];
        [label setFont:font];
        [contentView addSubview:label];
        packageInstallDateLabel_ = label;

        UIImageView *imageView;
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [contentView addSubview:imageView];
        packageIdentifierImageView_ = imageView;

        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setImage:installDateImage$];
        [contentView addSubview:imageView];
        packageInstallDateImageView_ = imageView;

        // Provide our own separator views for more control.
        UIView *separatorView;

        separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        separatorView.backgroundColor = [UIColor colorWithRed:(200.0 / 255.0) green:(199.0 / 255.0) blue:(204.0 / 255.0) alpha:1.0];
        separatorView.hidden = YES;
        [self addSubview:separatorView];
        topSeparatorView_ = separatorView;

        separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        separatorView.backgroundColor = [UIColor colorWithRed:(200.0 / 255.0) green:(199.0 / 255.0) blue:(204.0 / 255.0) alpha:1.0];
        [self addSubview:separatorView];
        bottomSeparatorView_ = separatorView;
    }
    return self;
}

- (void)dealloc {
    [nameLabel_ release];
    [packageNameLabel_ release];
    [packageIdentifierLabel_ release];
    [packageInstallDateLabel_ release];
    [packageIdentifierImageView_ release];
    [packageInstallDateImageView_ release];
    [super dealloc];
}

#pragma mark - View (Layout)

- (void)layoutSubviews {
    [super layoutSubviews];

    const CGSize contentSize = [[self contentView] bounds].size;
    CGSize maxSize = CGSizeMake(contentSize.width - kContentInset.left - kContentInset.right, 10000.0);

    // Name.
    CGRect nameLabelFrame = CGRectZero;
    if ([[nameLabel_ text] length] > 0) {
        nameLabelFrame = [nameLabel_ frame];
        nameLabelFrame.origin.x = kContentInset.left;
        nameLabelFrame.origin.y = kContentInset.top;
        nameLabelFrame.size = [nameLabel_ sizeThatFits:maxSize];
    }
    [nameLabel_ setFrame:nameLabelFrame];

    maxSize.width -= 2.0;

    CGFloat x;
    CGFloat y;

    // Package name.
    x = kContentInset.left + 2.0;
    y = (nameLabelFrame.origin.y + nameLabelFrame.size.height);
    CGRect packageNameLabelFrame = CGRectZero;
    if ([[packageNameLabel_ text] length] > 0) {
        // Package name label.
        packageNameLabelFrame = [packageNameLabel_ frame];
        packageNameLabelFrame.origin.x = x;
        packageNameLabelFrame.origin.y = y;
        packageNameLabelFrame.size = [packageNameLabel_ sizeThatFits:maxSize];
    }
    [packageNameLabel_ setFrame:packageNameLabelFrame];

    // Package identifier.
    x = kContentInset.left + 2.0;
    y = (packageNameLabelFrame.origin.y + packageNameLabelFrame.size.height);
    CGRect packageIdentifierLabelFrame = CGRectZero;
    CGRect packageIdentifierImageViewFrame = CGRectZero;
    if ([[packageIdentifierLabel_ text] length] > 0) {
        // Package identifier icon.
        [packageIdentifierImageView_ sizeToFit];
        packageIdentifierImageViewFrame = [packageIdentifierImageView_ frame];
        packageIdentifierImageViewFrame.origin.x = x;
        packageIdentifierImageViewFrame.origin.y = y;

        // Package identifier label.
        packageIdentifierLabelFrame = [packageIdentifierLabel_ frame];
        packageIdentifierLabelFrame.origin.x = x + packageIdentifierImageViewFrame.size.width + 2.0;
        packageIdentifierLabelFrame.origin.y = y;
        packageIdentifierLabelFrame.size = [packageIdentifierLabel_ sizeThatFits:maxSize];
    }
    [packageIdentifierImageView_ setFrame:packageIdentifierImageViewFrame];
    [packageIdentifierLabel_ setFrame:packageIdentifierLabelFrame];

    // Package install date.
    x = kContentInset.left + 2.0;
    y = (packageIdentifierLabelFrame.origin.y + packageIdentifierLabelFrame.size.height);
    CGRect packageInstallDateLabelFrame = CGRectZero;
    CGRect packageInstallDateImageViewFrame = CGRectZero;
    if ([[packageInstallDateLabel_ text] length] > 0) {
        // Package install date icon.
        [packageInstallDateImageView_ sizeToFit];
        packageInstallDateImageViewFrame = [packageInstallDateImageView_ frame];
        packageInstallDateImageViewFrame.origin.x = x;
        packageInstallDateImageViewFrame.origin.y = y;

        // Package install date label.
        packageInstallDateLabelFrame = [packageInstallDateLabel_ frame];
        packageInstallDateLabelFrame.origin.x = x + packageInstallDateImageViewFrame.size.width + 2.0;
        packageInstallDateLabelFrame.origin.y = y;
        packageInstallDateLabelFrame.size = [packageInstallDateLabel_ sizeThatFits:maxSize];
    }
    [packageInstallDateImageView_ setFrame:packageInstallDateImageViewFrame];
    [packageInstallDateLabel_ setFrame:packageInstallDateLabelFrame];

    // Separators.
    const CGFloat scale = [[UIScreen mainScreen] scale];
    const CGFloat separatorHeight = 1.0 / scale;
    const CGSize size = self.bounds.size;
    [topSeparatorView_ setFrame:CGRectMake(0.0, 0.0, size.width, separatorHeight)];
    [bottomSeparatorView_ setFrame:CGRectMake(0.0, size.height - separatorHeight, size.width, separatorHeight)];
}

#pragma mark - Properties

- (void)setText:(NSString *)text forLabel:(UILabel *)label {
    const NSUInteger oldLength = [[label text] length];
    const NSUInteger newLength = [text length];

    [label setText:text];

    if (((oldLength == 0) && (newLength != 0)) || ((oldLength != 0) && (newLength == 0))) {
        [self setNeedsLayout];
    }
}

- (void)setName:(NSString *)name {
    [self setText:name forLabel:nameLabel_];
}

- (void)setPackageName:(NSString *)packageName {
    [self setText:packageName forLabel:packageNameLabel_];
}

- (void)setPackageIdentifier:(NSString *)packageIdentifier {
    [self setText:packageIdentifier forLabel:packageIdentifierLabel_];
}

- (void)setPackageInstallDate:(NSString *)packageInstallDate {
    if ([packageInstallDate length] != 0) {
        packageInstallDate = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PACKAGE_INSTALL_DATE_PREFIX", nil), packageInstallDate];
    }
    [self setText:packageInstallDate forLabel:packageInstallDateLabel_];
}

- (void)setPackageType:(BinaryImageCellPackageType)packageType {
    if (packageType_ != packageType) {
        packageType_ = packageType;

        UIImage *image = nil;
        switch (packageType_) {
            case BinaryImageCellPackageTypeApple: image = appleImage$; break;
            case BinaryImageCellPackageTypeDebian: image = debianImage$; break;
            default: break;
        }
        [packageIdentifierImageView_ setImage:image];
        [self setNeedsLayout];
    }
}

- (void)setNewer:(BOOL)newer {
    if (newer_ != newer) {
        newer_ = newer;
        [packageInstallDateLabel_ setTextColor:(newer_ ? kColorNewer : kColorInstallDate)];
    }
}

- (void)setRecent:(BOOL)recent {
    if (recent_ != recent) {
        recent_ = recent;
        [packageInstallDateLabel_ setTextColor:(recent_ ? kColorRecent : kColorInstallDate)];
    }
}

- (void)setFromUnofficialSource:(BOOL)fromUnofficialSource {
    if (fromUnofficialSource_ != fromUnofficialSource) {
        fromUnofficialSource_ = fromUnofficialSource;
        [[self contentView] setBackgroundColor:(fromUnofficialSource_ ? kColorFromUnofficialSource : [UIColor whiteColor])];
    }
}

- (BOOL)showsTopSeparator {
    return topSeparatorView_.hidden;
}

- (void)setShowsTopSeparator:(BOOL)shows {
    topSeparatorView_.hidden = !shows;
}

@end

/* vim: set ft=objc ff=unix sw=4 ts=4 tw=80 expandtab: */
