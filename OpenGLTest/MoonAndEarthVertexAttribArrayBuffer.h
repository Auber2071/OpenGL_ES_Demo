//
//  MoonAndEarthVertexAttribArrayBuffer.h
//  OpenGLTest
//
//  Created by Edward on 2022/2/10.
//  Copyright © 2024 Edward. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : GLint {
    YSGLKVertexAttribPosition = GLKVertexAttribPosition,
    YSGLKVertexAttribNormal = GLKVertexAttribNormal,
    YSGLKVertexAttribColor = GLKVertexAttribColor,
    YSGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    YSGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1
} YSGLKVertexAttrib;

@interface MoonAndEarthVertexAttribArrayBuffer : NSObject

@property (nonatomic, assign, readonly) GLuint name;
@property (nonatomic, assign, readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic, assign, readonly) GLuint stride;

+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;

- (id)initWithAttribStride:(GLuint)stride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)reinitWithAttribStride:(GLuint)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;

@end


NS_ASSUME_NONNULL_END
