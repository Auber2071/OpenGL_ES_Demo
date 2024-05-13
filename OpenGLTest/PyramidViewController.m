//
//  PyramidViewController.m
//  OpenGLTest
//
//  Created by Edward on 2018/8/20.
//  Copyright © 2018年 Edward. All rights reserved.
//

#import "PyramidViewController.h"

#define topNumbers  18//3的倍数

@interface PyramidViewController () {
    GLKVector3 _vertex[8];
    GLKVector4 _colors[8];
    GLKVector2 _texturePosition[4];
    
    GLKVector3 _triangleVertex[topNumbers];
    GLKVector4 _triangleColor[topNumbers];
    GLKVector2 _triangleTexture[topNumbers];
    
    GLKVector3 _rotation;
    GLKVector3 _rotationVelocity;
    
    GLKBaseEffect *_effect;
}

@end

@implementation PyramidViewController

- (void)loadView {
    [super loadView];
    EAGLRenderingAPI renderingAPI = kEAGLRenderingAPIOpenGLES3;
    //每个上下文都针对特定版本的OpenGL ES
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:renderingAPI];
    if (context == nil) {
        renderingAPI = kEAGLRenderingAPIOpenGLES2;
        context = [[EAGLContext alloc] initWithAPI:renderingAPI];
    }
    //将context设置为当前线程的上下文，请在将新上下文设置为当前上下文之前调用glFlush函数，这样可以确保先前提交的命令及时传递给图形硬件。
    [EAGLContext setCurrentContext:context];
    
    GLKView *view = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds] context:context];
    view.delegate = self;
    self.view = view;
    
    _rotationVelocity = GLKVector3Make(0.3, 0.5, 0.4);
    _rotation = GLKVector3Make(0.0 * M_PI, 0.0 * M_PI, 0.0 * M_PI);
    [self setupData];
    [self setupEffect];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupData {
    _vertex[0] = GLKVector3Make(0.0, 0.5,  0.0);  // 上
    _vertex[1] = GLKVector3Make( -0.5, -0.5, 0.5);//前左下
    _vertex[2] = GLKVector3Make( 0.5, -0.5, 0.5); //前右下
    _vertex[3] = GLKVector3Make(-0.5, -0.5, -0.5);//后左下
    _vertex[4] = GLKVector3Make(0.5, -0.5, -0.5); //后右下

    _colors[0] = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
    _colors[1] = GLKVector4Make(0.0, 1.0, 0.0, 1.0);
    _colors[2] = GLKVector4Make(0.0, 0.0, 1.0, 1.0);
    _colors[3] = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    _colors[4] = GLKVector4Make(0.0, 1.0, 1.0, 1.0);

    _texturePosition[0] = GLKVector2Make(0, 0); //左下
    _texturePosition[1] = GLKVector2Make(1, 0); //右下
    _texturePosition[2] = GLKVector2Make(1, 1); //右上
    _texturePosition[3] = GLKVector2Make(0, 1); //左上

    ///索引缓冲对象 IBO/EBO
    ///文理索引
    int textureIndeices[topNumbers] = {
        0, 1, 2,
        0, 2, 3,
        0, 1, 2,
        0, 2, 3,
        0, 1, 2,
        0, 2, 3
    };

    ///顶点索引
    int vertexIndices[topNumbers] = {
        0, 1, 2,
        0, 2, 4,
        0, 4, 3,
        0, 3, 1,
        1, 3, 4,
        1, 4, 2
    };
    for (int i = 0; i < topNumbers; i++) {
        _triangleVertex[i] = _vertex[vertexIndices[i]];
        _triangleColor[i] = _colors[vertexIndices[i]];
        _triangleTexture[i] = _texturePosition[textureIndeices[i]];
    }
}

- (void)setupEffect {
    
    _effect = [[GLKBaseEffect alloc] init];

    //加载纹理图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cat" ofType:@"JPG"];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(1)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
    //设置纹理可用
    _effect.texture2d0.enabled = GL_TRUE;
    //传递纹理信息
    _effect.texture2d0.name = textureInfo.name;
}

#pragma mark - 绘制

- (void)update {
    NSTimeInterval time = [self timeSinceLastDraw];
    _rotation = GLKVector3Add(_rotation, GLKVector3MultiplyScalar(_rotationVelocity, time));
}

/// GLKViewDelegate required method
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    ///注意：glClear函数提示OpenGL ES可以丢弃任何现有的帧缓冲区内容，避免了昂贵的内存操作将以前的内容加载到内存中。 为确保最佳性能，您应该在绘制之前始终调用此函数。
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(0, 0, 0);
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(_rotation.x);
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(_rotation.y);
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(_rotation.z);
    GLKMatrix4 transform = GLKMatrix4Multiply(zRotationMatrix, GLKMatrix4Multiply(yRotationMatrix, xRotationMatrix));
    transform = GLKMatrix4Multiply(translation, transform);
    GLKMatrix4 lookAt = GLKMatrix4MakeLookAt(0, 0, 5, 0, 0, 0, 0, 1, 0);//GLKMatrix4Identity

    //用于将位置坐标从世界空间转换到眼睛空间的矩阵。
    _effect.transform.modelviewMatrix = GLKMatrix4Multiply(lookAt, transform);

    //用于将位置坐标从眼睛空间转换到投影空间的矩阵。
    /**
     //GLKMatrix4MakePerspective:返回4x4透视投影矩阵。
     1.垂直观察区域的角度。
     2.水平和垂直观看面积之比。
     3.距离不远的剪裁。必须是正数
     4.距离遥远的剪裁。必须是正的并且大于近距离。
     */
    _effect.transform.projectionMatrix = GLKMatrix4MakePerspective(0.25 * M_PI, self.view.bounds.size.width / self.view.bounds.size.height, 3, 7);

    [_effect prepareToDraw];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    /**
        1.状态设置函数：这类函数将会改变上下文
        2.状态使用函数：这类函数会根据当前OpenGL的状态执行一些操作。
        3.OpenGL本质上是个大状态机
        4.对象代表OpenGL状态的一个子集
     */
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    /**
     glVertexAttribPointer 函数告诉OpenGL该如何解析顶点数据
     1.属性类型
     2.顶点属性的大小
     3.指定数据的类型
     4.定义我们是否希望数据被标准化，GL_TRUE:所有数据都会被映射到0(对于有符号行signed数据是-1)-1之间。
     5.步长，顶点属性组之间的间隔。设置为0时，让OpenGL决定具体步长是多少(只有当数值是紧密排列时才可用)
     6.偏移量：位置数据在缓冲中其实位置的偏移量
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_TRUE, 0, _triangleVertex);
    
    //glEnableVertexAttribArray(GLKVertexAttribColor);
    //glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, _triangleColor);

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_TRUE, 0, _triangleTexture);

    /**
     1.图元
     2.顶点数组的起始索引
     3.绘制顶点数量
     */
    glDrawArrays(GL_TRIANGLES, 0, topNumbers);//改变OpenGL的状态为绘制xxx
    //glDrawArrays(GL_LINE_STRIP, 0, topNumbers);//改变OpenGL的状态为绘制xxx

    glDisableVertexAttribArray(GLKVertexAttribPosition);
    //glDisableVertexAttribArray(GLKVertexAttribColor);
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
}

@end
