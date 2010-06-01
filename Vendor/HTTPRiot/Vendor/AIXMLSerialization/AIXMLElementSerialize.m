//
//  NSXMLElement+Serialize.m
//  AIXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import "AIXMLElementSerialize.h"

@implementation NSXMLElement (Serialize)

// Should this be configurable?  Ruby's XmlSimple handles nodes with 
// string values and attributes by assigning the string value to a 
// 'content' key, although that seems like a pretty generic key which 
// could cause collisions if an element has a 'content' attribute.
static NSString *contentItem;
+ (void)initialize
{
    if(!contentItem)
        contentItem = @"content";
}

- (NSDictionary *)attributesAsDictionary
{
	NSArray *attributes = [self attributes];
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[attributes count]];
	
	uint i;
	for(i = 0; i < [attributes count]; i++)
	{
		NSXMLNode *node = [attributes objectAtIndex:i];
		[result setObject:[node stringValue] forKey:[node name]];
	}
	return result;
}

- (NSMutableDictionary *)toDictionary
{
    id out, rawObj, nodeObj;
    NSXMLNode *node;
    NSArray *nodes = [self children];
    NSString *elName = [self name], *key;
    NSDictionary *attrs = [self attributesAsDictionary];
    NSString *type = [attrs valueForKey:@"type"];
    NSMutableDictionary *groups = [NSMutableDictionary dictionary];
    NSMutableArray *objs;
    
    for(node in nodes)
    {
        // It's an element, lets create the proper groups for these elements
        // consolidating any duplicate elements at this level.
        if([node kind] == NSXMLElementKind)
        {
            NSString *childName = [node name];
            NSMutableArray *group = [groups objectForKey:childName];
            if(!group)
            {
                group = [NSMutableArray array];
                [groups setObject:group forKey:childName];
            }

            [group addObject:node];
        } 

        // We're on a text node so the parent node will be this nodes name.
        // Once we get done parsing this text node we can go ahead and return 
        // its dictionary rep because there is no need for further processing.
        else if([node kind] == NSXMLTextKind) 
        {
            NSXMLElement *containerObj = (NSXMLElement *)[node parent];
            NSDictionary *nodeAttrs = [containerObj attributesAsDictionary]; 
            NSString *contents = [node stringValue];
            
                        
            // If this node has attributes and content text we need to 
            // create a dictionary for it and use the static contentItem 
            // value as a place to store the stringValue.
            if([nodeAttrs count] > 0 && contents)
            {
                nodeObj = [NSMutableDictionary dictionaryWithObject:contents forKey:contentItem];
                [nodeObj addEntriesFromDictionary:nodeAttrs];
            }
            // Else this node only has a string value or is empty so we set 
            // it's value to a string.
            else
            {
                nodeObj = contents;
            }
            
            return [NSMutableDictionary dictionaryWithObject:nodeObj forKey:[containerObj name]];
        }
    }
    
    // Array
    // We have an element who says it's children should be treated as an array.
    // Instead of creating {:child_name => {:other, :attrs}} children, we create 
    // an array of anonymous dictionaries. [{:other, :attrs}, {:other, :attrs}]
    if([type isEqualToString:@"array"])
    {
        out = [NSMutableArray array];
        for(key in groups)
        {
            NSMutableDictionary *dictRep;
            objs = [groups objectForKey:key];  
            for(rawObj in objs)
            {
                dictRep = [rawObj toDictionary];
                [out addObject:[dictRep valueForKey:key]];
            }
        }        
    }
    
    // Dictionary
    else
    {
        out = [NSMutableDictionary dictionary];
        for(key in groups)
        {
            NSMutableDictionary *dictRep;
            objs = [groups objectForKey:key];
            if([objs count] == 1)
            {                
                dictRep = [[objs objectAtIndex:0] toDictionary];
                [out addEntriesFromDictionary:dictRep];
            }
            else
            {
                NSMutableArray *dictCollection = [NSMutableArray array];
                for(rawObj in objs)
                {
                    dictRep = [rawObj toDictionary];                    
                    id finalItems = [dictRep valueForKey:key];
                    [dictCollection addObject:finalItems];
                }
                
                [out setObject:dictCollection forKey:key];
            }
        }
        
        if([attrs count] > 0)
            [out addEntriesFromDictionary:attrs];
    }
    
    return [NSMutableDictionary dictionaryWithObject:out forKey:elName];
}
@end
