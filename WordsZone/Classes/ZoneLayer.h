//
//  ZoneLayer.h
//  WordsZone
//
//  Created by mmcl on 12-1-8.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ZoneLayer : CCLayer {
	NSMutableArray* m_movableObjList;
	CCTMXTiledMap* m_map;
	CCSprite*  m_selObj;
}

@end
