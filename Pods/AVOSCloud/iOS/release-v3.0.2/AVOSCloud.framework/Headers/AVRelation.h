//
//  AVRelation.h
//  AVOS Cloud
//
//

#import <Foundation/Foundation.h>
#import "AVObject.h"
#import "AVQuery.h"

/*!
 A class that is used to access all of the children of a many-to-many relationship.(一个类,用于访问所有的多对多关系。)  Each instance
 of AVRelation is associated with a particular parent object and key.(每一个AVRelation的实例是被关联到一个特定的父类对象和key)
 */
@interface AVRelation : NSObject {
    
}

@property (nonatomic, retain) NSString *targetClass;


#pragma mark Accessing objects
/*!
 @return A AVQuery that can be used to get objects in this relation.
 */
- (AVQuery *)query;


#pragma mark Modifying relations

/*!
 Adds a relation to the passed in object.
 @param object AVObject to add relation to.
 */
- (void)addObject:(AVObject *)object;

/*!
 Removes a relation to the passed in object.
 @param object AVObject to add relation to.
 */
- (void)removeObject:(AVObject *)object;

/*!
 @return A AVQuery that can be used to get parent objects in this relation.
 */

/**
 *  A AVQuery that can be used to get parent objects in this relation.
 *
 *  @param parentClassName parent Class Name
 *  @param relationKey     relation Key
 *  @param child           child object
 *
 *  @return the Query
 */
+(AVQuery *)reverseQuery:(NSString *)parentClassName
             relationKey:(NSString *)relationKey
             childObject:(AVObject *)child;

@end




