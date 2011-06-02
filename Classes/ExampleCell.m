//
//  ExampleCell.m
//  SwipeableExample
//
//  Created by Tom Irving on 16/06/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "ExampleCell.h"

@implementation ExampleCell
@synthesize delegate;
@synthesize text;

- (void)setText:(NSString *)aString {
	
	if (aString != text){
		[text release];
		text = [aString retain];
		[self setNeedsDisplay];
	}
}

- (void)buttonWasTapped:(UIButton *)button {
	
	if ([delegate respondsToSelector:@selector(cellBackButtonWasTapped:)]){
		[delegate cellBackButtonWasTapped:self];
	}
}

- (void)backViewWillAppear {
	
    
	UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button addTarget:self action:@selector(buttonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
    
	//[button setTitle:@"Tap me" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(20, 4, (self.backView.frame.size.width - 40) / 4, self.backView.frame.size.height - 8)];
    
    [button setImage:[UIImage imageNamed:@"favorited.png"] forState:UIControlStateNormal];
	[self.backView addSubview:button];
    
    
    //--------------------------------
    UIButton * button1 = [UIButton buttonWithType:UIButtonTypeCustom];
	[button1 addTarget:self action:@selector(buttonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
    
	//[button setTitle:@"Tap me" forState:UIControlStateNormal];
	[button1 setFrame:CGRectMake(20 + 40, 4, (self.backView.frame.size.width - 40) / 4, self.backView.frame.size.height - 8)];
    
    [button1 setImage:[UIImage imageNamed:@"Replies.tiff"] forState:UIControlStateNormal];
	[self.backView addSubview:button1];
    
}

- (void)backViewDidDisappear {
	// Remove any subviews from the backView.
	
	for (UIView * subview in self.backView.subviews){
		[subview removeFromSuperview];
	}
}

- (void)drawContentView:(CGRect)rect {
	
	UIColor * textColour = [UIColor blackColor];
	
	if (self.selected) {
		textColour = [UIColor whiteColor];
		[[UIImage imageNamed:@"selectiongradient.png"] drawInRect:rect];
	}
	
	[textColour set];
	
	UIFont * textFont = [UIFont boldSystemFontOfSize:22];
	
	CGSize textSize = [text sizeWithFont:textFont constrainedToSize:rect.size];
	[text drawInRect:CGRectMake((rect.size.width / 2) - (textSize.width / 2), 
								(rect.size.height / 2) - (textSize.height / 2),
								textSize.width, textSize.height)
			withFont:textFont];
}

- (void)drawBackView:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIImage imageNamed:@"meshpattern.png"] drawAsPatternInRect:rect];
	[self drawShadowsWithHeight:10 opacity:0.3 InRect:rect forContext:context];
}

- (void)drawShadowsWithHeight:(CGFloat)shadowHeight opacity:(CGFloat)opacity InRect:(CGRect)rect forContext:(CGContextRef)context {
	
	CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
	
	CGFloat topComponents[8] = {0, 0, 0, opacity, 0, 0, 0, 0};
	CGGradientRef topGradient = CGGradientCreateWithColorComponents(space, topComponents, nil, 2);
	CGPoint finishTop = CGPointMake(rect.origin.x, rect.origin.y + shadowHeight);
	CGContextDrawLinearGradient(context, topGradient, rect.origin, finishTop, kCGGradientDrawsAfterEndLocation);
	
	CGFloat bottomComponents[8] = {0, 0, 0, 0, 0, 0, 0, opacity};
	CGGradientRef bottomGradient = CGGradientCreateWithColorComponents(space, bottomComponents, nil, 2);
	CGPoint startBottom = CGPointMake(rect.origin.x, rect.size.height - shadowHeight);
	CGPoint finishBottom = CGPointMake(rect.origin.x, rect.size.height);
	CGContextDrawLinearGradient(context, bottomGradient, startBottom, finishBottom, kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(topGradient);
	CGGradientRelease(bottomGradient);
}

- (void)dealloc {
	
	[text release];
    [super dealloc];
}

@end
