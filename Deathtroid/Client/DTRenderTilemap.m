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
#import "DTWorldRoom.h"
#import "DTMap.h"
#import "DTProgram.h"
#import <OpenGL/gl.h>

@implementation DTRenderTilemap {
	DTResourceManager *resources;
}
-(id)init;
{
	if(!(self = [super init])) return nil;
	
	resources = [DTResourceManager sharedManager];
	
	return self;
}
-(void)drawLayer:(DTLayer*)layer camera:(DTCamera*)camera fromWorldRoom:(DTWorldRoom*)worldRoom
{
    DTProgram *p = [resources resourceNamed:@"main.program"];
    GLint scl = glGetUniformLocation(p.programName, "cycleSourceColor");
    GLint dcl = glGetUniformLocation(p.programName, "cycleDestColor");
    	
    if(layer.cycleColors) {
        DTColor *c = [worldRoom cyclingColorForLayer:layer];
        glUniform4f(scl, layer.cycleSource.r, layer.cycleSource.g, layer.cycleSource.b, layer.cycleSource.a);
        glUniform4f(dcl, c.r, c.g, c.b, c.a);            
    } else {
        // Set to some other value, like -1, or maybe don't use shader?
    }
    
	DTTexture *texture = [resources resourceNamed:$sprintf(@"%@.texture", layer.tilesetName)];
	[texture use];
	
    glPushMatrix();
    
    // Calc translation from repeat settings
    float camx = -camera.position.x * layer.depth;
    float camy = -camera.position.y * layer.depth;
    
    while(layer.repeatX && camx < -layer.map.width) {
        camx += layer.map.width;
    }
    while(layer.repeatY && camy < -layer.map.height) {
        camy += layer.map.height;
    }
        
	glTranslatef(camx, camy, 0);
    
    float scale = 16. / texture.pixelSize.width;
    
    [self drawMap:layer.map textureScale:scale];
    if(layer.repeatX) {
        glPushMatrix();
        glTranslatef(layer.map.width, 0, 0);
        [self drawMap:layer.map textureScale:scale];
        glPopMatrix();
    }
    if(layer.repeatY) {
        glPushMatrix();
        glTranslatef(0, layer.map.height, 0);
        [self drawMap:layer.map textureScale:scale];
        glPopMatrix();
    }
    if(layer.repeatX && layer.repeatY) {
        glPushMatrix();
        glTranslatef(layer.map.width, layer.map.height, 0);
        [self drawMap:layer.map textureScale:scale];
        glPopMatrix();
    }
    
	glPopMatrix();
}

-(void)drawCollision:(DTMap*)map camera:(DTCamera*)camera; 
{
	DTTexture *texture = [resources resourceNamed:@"collision.texture"];
	[texture use];
	glPushMatrix();
	glTranslatef(-camera.position.x, -camera.position.y, 0);
    [self drawMap:map textureScale:16 / texture.pixelSize.width];
	glPopMatrix();

}

-(void)drawMap:(DTMap*)map textureScale:(float)scale;
{    
	glBegin(GL_QUADS);
	glColor3f(1,1,1);
    for(int h=0; h<map.height; h++) {
        for(int w=0; w<map.width; w++) {
            int x = w;
            int y = h;
                    
            int tile = map.tiles[h*map.width+w];
            int attr = map.attr != NULL ? map.attr[h*map.width+w] : 0;
            if(tile == 0) continue;
            tile--;
            float ru = (attr & 1)?-scale:scale;
            float rv = (attr & 2)?-scale:scale;
            float u = scale * (int)(tile % 8) + ((attr&1)?scale:0);
            float v = scale * (int)(tile / 8) + ((attr&2)?scale:0);
            
            if(!(attr & 4)) {
                glTexCoord2f(u, v);         glVertex2f(x, y);
                glTexCoord2f(u+ru, v);      glVertex2f(x+1, y);
                glTexCoord2f(u+ru, v+rv);   glVertex2f(x+1, y+1);
                glTexCoord2f(u, v+rv);      glVertex2f(x, y+1);
            } else {
                // Rotated 90 degrees
                glTexCoord2f(u, v+rv);      glVertex2f(x, y);
                glTexCoord2f(u, v);         glVertex2f(x+1, y);
                glTexCoord2f(u+ru, v);      glVertex2f(x+1, y+1);
                glTexCoord2f(u+ru, v+rv);   glVertex2f(x, y+1);
            }
        }
    }
	glEnd();
}

@end
