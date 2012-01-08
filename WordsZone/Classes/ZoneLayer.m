//
//  ZoneLayer.m
//  WordsZone
//
//  Created by mmcl on 12-1-8.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneLayer.h"

enum MapTag {
	kTagTileMap
};

@implementation ZoneLayer

- (void)_AddObjectBar
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite* obj1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	obj1.position = ccp( 30, s.height/2);
	[self addChild:obj1 z:1];
	
	m_movableObjList = [[NSMutableArray alloc] init];
	[m_movableObjList addObject:obj1];
}

- (void)_AddMap
{
	CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"iso-test-zorder.tmx"];
	m_map = map;
	
	[self addChild:map z:0 tag:kTagTileMap];
	
	
	CGSize s = map.contentSize;
	NSLog(@"ContentSize: %f, %f", s.width,s.height);
	
	[map setPosition:ccp(-s.width/2 + 500,0)];
	
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.isTouchEnabled = YES;
		
		[self _AddObjectBar];
		
		[self _AddMap];
	}
	return self;
}

- (void)dealloc
{
	[m_movableObjList release];
	
	[super dealloc];
}

- (void)_SelectObjForTouch:(CGPoint)touchPos
{
	for (CCSprite *obj in m_movableObjList) {
        if (CGRectContainsPoint(obj.boundingBox, touchPos)) {            
			[m_map removeChild:m_selObj cleanup:YES];
            m_selObj = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
			CGPoint pos = [m_map convertToNodeSpace: touchPos];
			m_selObj.position = pos;
			m_selObj.anchorPoint = ccp(0.5f, 0.f);
			[m_map addChild:m_selObj z:1];
			
            break;
        }
    }    
}

- (CGPoint)_TilePosFromMapPos:(CGPoint)pos
{
	CGSize mapSize = m_map.mapSize;
	CGSize tileSize = m_map.tileSize;
	
	CGFloat tx = (int)(pos.x/tileSize.width - pos.y/tileSize.height - mapSize.width*(0.5f) + mapSize.height);
	CGFloat ty = (int)(-pos.x/tileSize.width - pos.y/tileSize.height + mapSize.width*(0.5f) + mapSize.height);
	return CGPointMake(tx, ty);
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchPos = [touch locationInView: [touch view]];
	touchPos = [[CCDirector sharedDirector] convertToGL: touchPos];
	touchPos = [self convertToNodeSpace: touchPos];
	[self _SelectObjForTouch:touchPos];
	
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {       
    CGPoint touchPos = [touch locationInView:touch.view];
	touchPos = [[CCDirector sharedDirector] convertToGL:touchPos];
	touchPos = [m_map convertToNodeSpace:touchPos];
	
    CGPoint oldTouchPos = [touch previousLocationInView:touch.view];
    oldTouchPos = [[CCDirector sharedDirector] convertToGL:oldTouchPos];
    oldTouchPos = [m_map convertToNodeSpace:oldTouchPos];
	
    CGPoint translation = ccpSub(touchPos, oldTouchPos);    

	NSLog(@"%f, %f", translation.x, translation.y);
	
	if (m_selObj) {
        CGPoint newPos = ccpAdd(m_selObj.position, translation);
        m_selObj.position = newPos;
		NSLog(@"new position: %f, %f", m_selObj.position.x, m_selObj.position.y);
    }
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchPos = [touch locationInView: [touch view]];
	touchPos = [[CCDirector sharedDirector] convertToGL: touchPos];
	touchPos = [m_map convertToNodeSpace: touchPos];
	
	CCTMXLayer* treeLayer = [m_map layerNamed:@"trees1"];
	//	
	CGPoint tilePos = [self _TilePosFromMapPos:touchPos];
	
	int tileGid = [treeLayer tileGIDAt:tilePos];
	BOOL canPlace = YES;
	if (tileGid) {
		NSDictionary *properties = [m_map propertiesForGID:tileGid];
		if (properties) {
			NSString *collision = [properties valueForKey:@"Collidable"];
			if (collision && [collision compare:@"TRUE"] == NSOrderedSame) {
				canPlace = NO;
			}
		}
	}
	
	if (m_selObj) {
		m_selObj.visible = canPlace;
		CGPoint mapPos = [treeLayer positionAt:tilePos];
		
		[m_selObj setPosition:ccp(mapPos.x + m_map.tileSize.width/2, mapPos.y + m_map.tileSize.height/2)];
	}
}


@end
