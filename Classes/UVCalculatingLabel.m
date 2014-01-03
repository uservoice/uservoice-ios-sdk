//
//  UVCalculatingLabel.m
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVCalculatingLabel.h"

@implementation UVCalculatingLabel

- (CGFloat)effectiveWidth {
    return self.frame.size.width;
}

- (CGRect)rectForLetterAtIndex:(NSUInteger)index {
    if (index > [self.text length] - 1)
        return CGRectZero;

    CGFloat frameWidth = [self effectiveWidth];
    NSString *letter = [self.text substringWithRange:NSMakeRange(index, 1)];
    CGSize letterSize = [letter sizeWithFont:self.font];
    
    NSArray *lines = [self breakString];
    int targetLineNumber = 0, targetColumnNumber = 0, elapsedChars = 0;
    NSString *targetLine = nil;
    for (int i = 0; i < [lines count]; i++) {
        NSString *line = [lines objectAtIndex:i];
        if (index >= elapsedChars + [line length]) {
            elapsedChars += [line length];
            targetLineNumber++;
        } else {
            targetLine = line;
            targetColumnNumber = index - elapsedChars;
            break;
        }
    }

    int linesThatFit = floor(self.frame.size.height / self.font.lineHeight);
    int totalLines = self.numberOfLines == 0 ? [lines count] : MIN([lines count], self.numberOfLines);
    int linesDisplayed = MIN(linesThatFit, totalLines);
    CGFloat targetLineWidth = [targetLine sizeWithFont:self.font].width;
    
    CGFloat x = [[targetLine substringWithRange:NSMakeRange(0, targetColumnNumber)] sizeWithFont:self.font].width;
    CGFloat y = self.frame.size.height/2 - (linesDisplayed*self.font.lineHeight)/2 + self.font.lineHeight*targetLineNumber;
    
    if (self.textAlignment == NSTextAlignmentCenter)
        x = x + (frameWidth-targetLineWidth)/2;
    else if (self.textAlignment == NSTextAlignmentCenter)
        x = frameWidth-(targetLineWidth-x);
    
    return CGRectMake(x, y, letterSize.width, letterSize.height);
}

- (NSArray *)breakString {
    NSMutableArray *lines = [NSMutableArray array];
    CGFloat frameWidth = [self effectiveWidth];
    int len = [self.text length];
    int lineStartOffset = 0;
    int lastBreakChar = -1;

    for (int i=0; i < len; i++) {
        int currentLineLength = i - lineStartOffset;
        NSString *currentChar = [self.text substringWithRange:NSMakeRange(i, 1)];
        NSString *currentLine = [self.text substringWithRange:NSMakeRange(lineStartOffset, currentLineLength)];
        if ([currentChar isEqualToString:@" "] || [currentChar isEqualToString:@"-"])
            lastBreakChar = i;
        
        CGSize currentSize = [currentLine sizeWithFont:self.font constrainedToSize:CGSizeMake(frameWidth, 1000) lineBreakMode:self.lineBreakMode];
        
        // TODO: Add support for hard breaks (\n)
        if (currentSize.height > self.font.lineHeight) {
            if (lastBreakChar == -1 || self.lineBreakMode == NSLineBreakByCharWrapping) {
                currentLine = [self.text substringWithRange:NSMakeRange(lineStartOffset, currentLineLength)];
                lineStartOffset = i;
                i--;
            } else {
                currentLine = [self.text substringWithRange:NSMakeRange(lineStartOffset, lastBreakChar - lineStartOffset + 1)];
                i = lineStartOffset = lastBreakChar + 1;
                lastBreakChar = -1;
            }
            [lines addObject:currentLine];
        }
    }
    [lines addObject:[self.text substringWithRange:NSMakeRange(lineStartOffset, len - lineStartOffset)]];
    return lines;
}

@end
