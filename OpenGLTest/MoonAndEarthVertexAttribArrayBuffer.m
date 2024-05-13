//
//  MoonAndEarthVertexAttribArrayBuffer.m
//  OpenGLTest
//
//  Created by Edward on 2022/2/10.
//  Copyright © 2024 Edward. All rights reserved.
//

#import "MoonAndEarthVertexAttribArrayBuffer.h"

@interface MoonAndEarthVertexAttribArrayBuffer()
@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;
@property (nonatomic, assign) GLuint stride;
@end

@implementation MoonAndEarthVertexAttribArrayBuffer

- (id)initWithAttribStride:(GLuint)aStride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage {
    
    NSParameterAssert(0 < aStride);
    NSAssert((0 < count && NULL != dataPtr) ||
             (0 == count && NULL == dataPtr),
             @"data must not be NULL or count > 0");
    
    if(nil != (self = [super init])) {
        
        _stride = aStride;
        _bufferSizeBytes = _stride * count;
        
        glGenBuffers(1, &_name);
        glBindBuffer(GL_ARRAY_BUFFER, self.name);
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, usage);
        
        NSAssert(0 != _name, @"Failed to generate name");
    }
    
    return self;
}


- (void)reinitWithAttribStride:(GLuint)aStride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr {
    
    NSParameterAssert(0 < aStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    NSAssert(0 != _name, @"Invalid name");
    
    self.stride = aStride;
    self.bufferSizeBytes = aStride * count;
    
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, GL_DYNAMIC_DRAW);
}

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable {
    
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != _name, @"Invalid name");
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    /**
     glVertexAttribPointer 函数告诉OpenGL该如何解析顶点数据
     1.属性类型
     2.顶点属性的大小
     3.指定数据的类型
     4.定义我们是否希望数据被标准化，GL_TRUE:所有数据都会被映射到0(对于有符号行signed数据是-1)-1之间。
     5.步长，顶点属性组之间的间隔。设置为0时，让OpenGL决定具体步长是多少(只有当数值是紧密排列时才可用)
     6.偏移量：位置数据在缓冲中其实位置的偏移量
     */
    if(shouldEnable) glEnableVertexAttribArray(index);
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride, NULL + offset);
#ifdef DEBUG
    GLenum error = glGetError();
    if(GL_NO_ERROR != error) {
        NSLog(@"GL Error: 0x%x", error);
    }
#endif
}

+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count {
    glDrawArrays(mode, first, count);
}

- (void)dealloc {
    if (0 != _name) {
        glDeleteBuffers (1, &_name); // Step 7
        _name = 0;
    }
}

@end
