//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"
#import "Globals.h"

#define ANIMATION_DURATION	0.30

#define HEADER_OFFSET 8

@interface EasyTableViewCell : UITableViewCell

- (void)prepareForReuse;

@end

@implementation EasyTableViewCell


- (void) prepareForReuse
{
  [super prepareForReuse];
  
  UIView *content = [self viewWithTag:CELL_CONTENT_TAG];
  if ([content respondsToSelector:@selector(prepareForReuse)]) {
    [content performSelector:@selector(prepareForReuse)];
  }
  self.backgroundColor = [UIColor clearColor];
}
@end


@interface EasyTableView ()
- (void)createTableWithOrientation:(EasyTableViewOrientation)orientation;
- (void)prepareRotatedView:(UIView *)rotatedView withIndexPath:(NSIndexPath *)indexPath;
- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EasyTableView

@synthesize delegate, cellBackgroundColor;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize orientation = _orientation;
@synthesize numberOfCells = _numItems;

#pragma mark -
#pragma mark Initialization


- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCols ofWidth:(CGFloat)width {
  if (self = [super initWithFrame:frame]) {
		_numItems			= numCols;
		_cellWidthOrHeight	= width;
		
		[self createTableWithOrientation:EasyTableViewOrientationHorizontal];
	}
  return self;
}


- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numRows ofHeight:(CGFloat)height {
  if (self = [super initWithFrame:frame]) {
		_numItems			= numRows;
		_cellWidthOrHeight	= height;
		
		[self createTableWithOrientation:EasyTableViewOrientationVertical];
  }
  return self;
}


- (void)createTableWithOrientation:(EasyTableViewOrientation)orientation {
	// Save the orientation so that the table view cell knows how to set itself up
	_orientation = orientation;
	
	UITableView *tableView;
	if (orientation == EasyTableViewOrientationHorizontal) {
		int xOrigin	= (self.bounds.size.width - self.bounds.size.height)/2;
		int yOrigin	= (self.bounds.size.height - self.bounds.size.width)/2;
		tableView	= [[TimingFunctionTableView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width)];
	}
	else
		tableView	= [[TimingFunctionTableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	
	tableView.tag				= TABLEVIEW_TAG;
	tableView.delegate			= self;
	tableView.dataSource		= self;
	tableView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  tableView.delaysContentTouches = NO;
	
	// Rotate the tableView 90 degrees so that it is horizontal
	if (orientation == EasyTableViewOrientationHorizontal)
		tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
	
	tableView.showsVerticalScrollIndicator	 = NO;
	tableView.showsHorizontalScrollIndicator = NO;
	tableView.backgroundColor = [UIColor clearColor];
	[self addSubview:tableView];
  
  [self initHeaders];
}

#pragma mark - Headers

- (void) initHeaders {
  [self.headerContainer removeFromSuperview];
  self.headerContainer = [[UIView alloc] initWithFrame:CGRectZero];
  [self addSubview:self.headerContainer];
  
  NSInteger max = [self numberOfSectionsInTableView:self.tableView];
  for (int i = 0; i < max; i++) {
    NSString *headerName = nil;
    if ([self.delegate respondsToSelector:@selector(easyTableView:stringForHorizontalHeaderInSection:)]) {
      headerName = [self.delegate easyTableView:self stringForHorizontalHeaderInSection:i];
    }
    
    if (headerName) {
      int headerOffsets = 0;
      int numCellsBefore = 0;
      NSInteger numCellsAfter = [self tableView:self.tableView numberOfRowsInSection:i];
      if (numCellsAfter == 0) continue;
      
      for (int j = 0; j <= i; j++) {
        headerOffsets += [self tableView:self.tableView heightForHeaderInSection:j];
        numCellsBefore += j < i ? [self tableView:self.tableView numberOfRowsInSection:j] : 0;
      }
      
      CGRect r = CGRectZero;
      r.origin.x = headerOffsets+numCellsBefore*_cellWidthOrHeight+HEADER_OFFSET;
      r.origin.y = 0;
      r.size.width = numCellsAfter*_cellWidthOrHeight-HEADER_OFFSET*2;
      r.size.height = 30;
      
      EasyTableTopHeaderView *header = [[EasyTableTopHeaderView alloc] initWithFrame:r];
      header.tag = i;
      [header setLabelText:headerName];
      [self.headerContainer addSubview:header];
    }
  }
  
  [self scrollViewDidScroll:self.tableView];
}

#pragma mark -
#pragma mark Properties

- (TimingFunctionTableView *)tableView {
	return (TimingFunctionTableView *)[self viewWithTag:TABLEVIEW_TAG];
}


- (NSArray *)visibleViews {
	NSArray *visibleCells = [self.tableView visibleCells];
	NSMutableArray *visibleViews = [NSMutableArray arrayWithCapacity:[visibleCells count]];
	
	for (UIView *aView in visibleCells) {
		[visibleViews addObject:[aView viewWithTag:CELL_CONTENT_TAG]];
	}
	return visibleViews;
}


- (CGPoint)contentOffset {
	CGPoint offset = self.tableView.contentOffset;
	
	if (_orientation == EasyTableViewOrientationHorizontal)
		offset = CGPointMake(offset.y, offset.x);
	
	return offset;
}


- (CGSize)contentSize {
	CGSize size = self.tableView.contentSize;
	
	if (_orientation == EasyTableViewOrientationHorizontal)
		size = CGSizeMake(size.height, size.width);
	
	return size;
}


- (void)setContentOffset:(CGPoint)offset {
	if (_orientation == EasyTableViewOrientationHorizontal)
		self.tableView.contentOffset = CGPointMake(offset.y, offset.x);
	else
		self.tableView.contentOffset = offset;
}


- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
	CGPoint newOffset;
	
	if (_orientation == EasyTableViewOrientationHorizontal) {
		newOffset = CGPointMake(offset.y, offset.x);
	}
	else {
		newOffset = offset;
	}
	[self.tableView setContentOffset:newOffset animated:animated];
}

- (void)setScrollFraction:(CGFloat)fraction animated:(BOOL)animated {
	CGFloat maxScrollAmount = [self contentSize].width - self.bounds.size.width;
  
	CGPoint offset = self.contentOffset;
	offset.x = maxScrollAmount * fraction;
	[self setContentOffset:offset animated:animated];
}

#pragma mark -
#pragma mark Selection

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	self.selectedIndexPath	= indexPath;
	CGPoint defaultOffset	= CGPointMake(0, indexPath.row  *_cellWidthOrHeight);
	
	[self.tableView setContentOffset:defaultOffset animated:animated];
}


- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
	if (![_selectedIndexPath isEqual:indexPath]) {
		NSIndexPath *oldIndexPath = [_selectedIndexPath copy];
		
		_selectedIndexPath = indexPath;
		
		UITableViewCell *deselectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:oldIndexPath];
		UITableViewCell *selectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
		
		if ([delegate respondsToSelector:@selector(easyTableView:selectedView:atIndexPath:deselectedView:)]) {
			UIView *selectedView = [selectedCell viewWithTag:CELL_CONTENT_TAG];
			UIView *deselectedView = [deselectedCell viewWithTag:CELL_CONTENT_TAG];
			
			[delegate easyTableView:self
                 selectedView:selectedView
                  atIndexPath:_selectedIndexPath
               deselectedView:deselectedView];
		}
	}
}

#pragma mark -
#pragma mark Multiple Sections

- (CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  if ([self tableView:tableView numberOfRowsInSection:section] > 0) {
    if ([delegate respondsToSelector:@selector(easyTableView:stringForVerticalHeaderInSection:)]) {
      if ([delegate easyTableView:self stringForVerticalHeaderInSection:section]) {
        return 30.f;
      }
    } else if ([delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
      UIView *headerView = [delegate easyTableView:self viewForHeaderInSection:section];
      if (_orientation == EasyTableViewOrientationHorizontal)
        return headerView.frame.size.width;
      else
        return headerView.frame.size.height;
    }
  }
  return 0.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  if ([delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
    UIView *footerView = [delegate easyTableView:self viewForFooterInSection:section];
		if (_orientation == EasyTableViewOrientationHorizontal)
			return footerView.frame.size.width;
		else
			return footerView.frame.size.height;
  }
  return 0.0;
}

- (UIView *)viewToHoldSectionView:(UIView *)sectionView {
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
	if (_orientation == EasyTableViewOrientationHorizontal)
		sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
	
	UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
	
	if (_orientation == EasyTableViewOrientationHorizontal) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	}
	else {
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if ([self tableView:tableView numberOfRowsInSection:section] > 0) {
    if ([delegate respondsToSelector:@selector(easyTableView:stringForVerticalHeaderInSection:)]) {
      NSString *s = [delegate easyTableView:self stringForVerticalHeaderInSection:section];
      
      if (s) {
        [[NSBundle mainBundle] loadNibNamed:@"EasyTableHeaderView" owner:self options:nil];
        [self.headerView setLabelText:s.uppercaseString];
        self.headerView.button.tag = section;
        return self.headerView;
      }
    } else if ([delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
      UIView *sectionView = [delegate easyTableView:self viewForHeaderInSection:section];
      return [self viewToHoldSectionView:sectionView];
    }
  }
  return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if ([delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
		UIView *sectionView = [delegate easyTableView:self viewForFooterInSection:section];
		return [self viewToHoldSectionView:sectionView];
  }
  return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  
  if ([delegate respondsToSelector:@selector(numberOfSectionsInEasyTableView:)]) {
    return [delegate numberOfSectionsInEasyTableView:self];
  }
  return 1;
}

#pragma mark -
#pragma mark Location and Paths

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath {
	UIView *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	return [cell viewWithTag:CELL_CONTENT_TAG];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
	NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
    
		if ([cell viewWithTag:CELL_CONTENT_TAG] == view) {
      indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (CGPoint)offsetForView:(UIView *)view {
	// Get the location of the cell
	CGPoint cellOrigin = [view convertPoint:view.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}

#pragma mark -
#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	//[self setSelectedIndexPath:indexPath];
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return _cellWidthOrHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([delegate respondsToSelector:@selector(easyTableView:heightOrWidthForCellAtIndexPath:)]) {
    return [delegate easyTableView:self heightOrWidthForCellAtIndexPath:indexPath];
  }
  return _cellWidthOrHeight;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Don't allow the currently selected cell to be selectable
  //	if ([_selectedIndexPath isEqual:indexPath]) {
  //		return nil;
  //	}
	return indexPath;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([delegate respondsToSelector:@selector(easyTableView:scrolledToOffset:)])
		[delegate easyTableView:self scrolledToOffset:self.contentOffset];
	
	CGFloat amountScrolled	= self.contentOffset.x;
	CGFloat maxScrollAmount = [self contentSize].width - self.bounds.size.width;
	
	if (amountScrolled > maxScrollAmount) amountScrolled = maxScrollAmount;
	if (amountScrolled < 0) amountScrolled = 0;
	
	if ([delegate respondsToSelector:@selector(easyTableView:scrolledToFraction:)])
		[delegate easyTableView:self scrolledToFraction:amountScrolled/maxScrollAmount];
  
  self.headerContainer.frame = CGRectMake(-self.contentOffset.x, 0, 0, 0);
  for (EasyTableTopHeaderView *header in self.headerContainer.subviews) {
    float mid = [self convertPoint:ccp(self.frame.size.width/2, 0) toView:header].x;
    float baseX = 1.5*_cellWidthOrHeight-HEADER_OFFSET;
    if (header.frame.size.width > baseX*2) {
      [header moveLabelToXPosition:MIN(MAX(mid, baseX), header.frame.size.width-baseX)];
    }
  }
}


#pragma mark -
#pragma mark TableViewDataSource

- (void)setCell:(UITableViewCell *)cell boundsForOrientation:(EasyTableViewOrientation)theOrientation {
	if (theOrientation == EasyTableViewOrientationHorizontal) {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, _cellWidthOrHeight);
	}
	else {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.width, _cellWidthOrHeight);
	}
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"EasyTableViewCell";
  
  UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[EasyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		[self setCell:cell boundsForOrientation:_orientation];
		
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Add a view to the cell's content view that is rotated to compensate for the table view rotation
		CGRect viewRect;
		if (_orientation == EasyTableViewOrientationHorizontal)
			viewRect = CGRectMake(0, 0, cell.bounds.size.height, cell.bounds.size.width);
		else
			viewRect = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
		
		UIView *rotatedView				= [[UIView alloc] initWithFrame:viewRect];
		rotatedView.tag					= ROTATED_CELL_VIEW_TAG;
		rotatedView.center				= cell.contentView.center;
		rotatedView.backgroundColor		= self.cellBackgroundColor;
		
		if (_orientation == EasyTableViewOrientationHorizontal) {
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		}
		else
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		// We want to make sure any expanded content is not visible when the cell is deselected
		rotatedView.clipsToBounds = YES;
		
		// Prepare and add the custom subviews
		[self prepareRotatedView:rotatedView withIndexPath:indexPath];
		
		[cell.contentView addSubview:rotatedView];
	}
	[self setCell:cell boundsForOrientation:_orientation];
	
	[self setDataForRotatedView:[cell.contentView viewWithTag:ROTATED_CELL_VIEW_TAG] forIndexPath:indexPath];
  cell.backgroundColor =[ UIColor clearColor];
  return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numOfItems = _numItems;
	
	if ([delegate respondsToSelector:@selector(numberOfCellsForEasyTableView:inSection:)]) {
		numOfItems = [delegate numberOfCellsForEasyTableView:self inSection:section];
	}
	
  return numOfItems;
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  if ([delegate respondsToSelector:@selector(easyTableViewWillEndDragging:withVelocity:targetContentOffset:)]) {
    [delegate easyTableViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
  }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if ([delegate respondsToSelector:@selector(easyTableViewDidEndScrollingAnimation:)]) {
    [delegate easyTableViewDidEndScrollingAnimation:self];
  }
}

#pragma mark -
#pragma mark Rotation

- (void) prepareRotatedView:(UIView *)rotatedView withIndexPath:(NSIndexPath *)indexPath {
  int headerHeight = 0;
  if (self.headerContainer.subviews.count > 0) {
    headerHeight = [self.headerContainer.subviews[0] frame].size.height*2/3;
  }
  
  CGRect r = rotatedView.bounds;
  r.origin.y += headerHeight;
  r.size.height -= headerHeight;
  
	UIView *content = [delegate easyTableView:self viewForRect:r withIndexPath:indexPath];
	
	// Add a default view if none is provided
	if (content == nil)
		content = [[UIView alloc] initWithFrame:r];
	
	content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	content.tag = CELL_CONTENT_TAG;
	[rotatedView addSubview:content];
}


- (void) setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath {
	UIView *content = [rotatedView viewWithTag:CELL_CONTENT_TAG];
	
  [delegate easyTableView:self setDataForView:content forIndexPath:indexPath];
}

- (void) reloadData {
  [self initHeaders];
  [self.tableView reloadData];
}

- (IBAction) verticalHeaderClicked:(id)sender {
  NSInteger section = [(UIView *)sender tag];
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end

@implementation EasyTableTopHeaderView

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.label = [[UILabel alloc] initWithFrame:frame];
    self.label.font = [UIFont fontWithName:[Globals font] size:15.f];
    self.label.textColor = [UIColor colorWithWhite:0.23f alpha:1.f];
    self.label.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25f];
    self.label.shadowOffset = CGSizeMake(0, 1);
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
    
    self.leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    self.leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    self.rightView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    self.rightView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    
    UIColor *color = [UIColor colorWithRed:179/255. green:172/255.f blue:93/255.f alpha:0.5f];
    self.leftView1.backgroundColor = color;
    self.leftView2.backgroundColor = color;
    self.rightView1.backgroundColor = color;
    self.rightView2.backgroundColor = color;
    
    [self addSubview:self.leftView1];
    [self addSubview:self.leftView2];
    [self addSubview:self.rightView1];
    [self addSubview:self.rightView2];
    
    [self setBackgroundColor:[UIColor clearColor]];
  }
  return self;
}

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  [self setLabelText:self.label.text];
}

- (void) setLabelText:(NSString *)labelText {
  self.label.text = labelText;
  CGSize size = [self.label.text sizeWithFont:self.label.font];
  
  self.label.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
  
  CGRect r;
  
  r = self.leftView1.frame;
  r.size.width = self.label.center.x - size.width/2 - 10;
  r.origin.y = self.label.center.y-1;
  self.leftView1.frame = r;
  
  r = self.leftView2.frame;
  r.size.width = self.leftView1.frame.size.width;
  r.origin.y = self.label.center.y+1;
  self.leftView2.frame = r;
  
  r = self.rightView1.frame;
  r.size.width = self.leftView1.frame.size.width;
  r.origin.x = self.frame.size.width-r.size.width;
  r.origin.y = self.leftView1.frame.origin.y;
  self.rightView1.frame = r;
  
  r = self.rightView2.frame;
  r.size.width = self.leftView1.frame.size.width;
  r.origin.x = self.rightView1.frame.origin.x;
  r.origin.y = self.leftView2.frame.origin.y;
  self.rightView2.frame = r;
}

- (void) moveLabelToXPosition:(float)x {
  float diff = x - self.label.center.x;
  self.label.center = CGPointMake(x, self.label.center.y);
  
  CGRect r = self.leftView1.frame;
  r.size.width += diff;
  self.leftView1.frame = r;
  
  r = self.leftView2.frame;
  r.size.width += diff;
  self.leftView2.frame = r;
  
  r = self.rightView1.frame;
  r.origin.x += diff;
  r.size.width -= diff;
  self.rightView1.frame = r;
  
  r = self.rightView2.frame;
  r.origin.x += diff;
  r.size.width -= diff;
  self.rightView2.frame = r;
}

@end

@implementation EasyTableHeaderView

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  [self setLabelText:[self.button titleForState:UIControlStateNormal]];
}

- (void) setLabelText:(NSString *)labelText {
  [self.button setTitle:labelText forState:UIControlStateNormal];
  
  CGSize size = [labelText sizeWithFont:self.button.titleLabel.font];
  
  CGRect r;
  
  r = self.leftView1.frame;
  r.origin.x = 3;
  r.size.width = self.button.center.x-size.width/2-5-r.origin.x;
  r.origin.y = self.button.center.y-2;
  self.leftView1.frame = r;
  
  r = self.leftView2.frame;
  r.size.width = self.leftView1.frame.size.width;
  r.origin.x = self.leftView1.frame.origin.x;
  r.origin.y = self.leftView1.frame.origin.y+2;
  self.leftView2.frame = r;
  
  r = self.rightView1.frame;
  r.size.width = self.leftView1.frame.size.width;
  r.origin.x = self.frame.size.width-self.leftView1.frame.origin.x-r.size.width;
  r.origin.y = self.leftView1.frame.origin.y;
  self.rightView1.frame = r;
  
  r = self.rightView2.frame;
  r.size.width = self.leftView1.frame.size.width;
  r.origin.x = self.rightView1.frame.origin.x;
  r.origin.y = self.leftView2.frame.origin.y;
  self.rightView2.frame = r;
}

@end
