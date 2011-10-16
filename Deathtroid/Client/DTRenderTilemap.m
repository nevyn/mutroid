//
//  DTRenderTilemap.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-15.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTRenderTilemap.h"
#import "DTTexture.h"
#import "DTCamera.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTProgram.h"
#import <OpenGL/gl.h>

@implementation DTRenderTilemap {
	DTResourceManager *resources;
}
-(id)init;
{
	if(!(self = [super init])) return nil;
	
	resources = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@"resources" withExtension:nil]];
	
	return self;
}
-(void)drawLayer:(DTLayer*)layer camera:(DTCamera*)camera;
{
    DTProgram *p = [resources resourceNamed:@"main.program"];
    GLint scl = glGetUniformLocation(p.programName, "cycleSourceColor");
    GLint dcl = glGetUniformLocation(p.programName, "cycleDestColor");
    	
    if(layer.cycleColors) {
        DTColor *c = [layer.cycleColors objectAtIndex:layer.cycleCurrent];
        glUniform4f(scl, layer.cycleSource.r, layer.cycleSource.g, layer.cycleSource.b, layer.cycleSource.a);
        glUniform4f(dcl, c.r, c.g, c.b, c.a);            
    } else {
        // Set to some other value, like -1, or maybe don't use shader?
    }
    

	DTTexture *texture = [resources resourceNamed:$sprintf(@"%@.texture", layer.tilemapName)];
	[texture use];
	glPushMatrix();
	glTranslatef(-camera.position.x * layer.depth, -camera.position.y * layer.depth, 0);
	glBegin(GL_QUADS);
	glColor3f(1,1,1);
	DTMap *map = layer.map;
	for(int i=0; i<(layer.repeatX?2:1); i++) {
		for(int h=0; h<map.height; h++) {
			for(int w=0; w<map.width; w++) {
			
				int x = i*map.width + w;
				int y = h;
			
				int tile = map.tiles[h*map.width+w];
				if(tile == 0) continue;
				tile--;
				float r = 0.125;
				float u = r * (int)(tile % 8);
				float v = r * (int)(tile / 8);
				glTexCoord2f(u, v); glVertex2f(x, y);
				glTexCoord2f(u+r, v); glVertex2f(x+1, y);
				glTexCoord2f(u+r, v+r); glVertex2f(x+1, y+1);
				glTexCoord2f(u, v+r); glVertex2f(x, y+1);
			}
		}
	}
	glEnd();
	glPopMatrix();
}

@end
