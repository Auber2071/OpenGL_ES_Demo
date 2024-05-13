//
//  PlanetViewController.m
//  OpenGLTest
//
//  Created by Edward on 2018/8/31.
//  Copyright © 2018年 Edward. All rights reserved.
//

#import "PlanetViewController.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define kCount 80
/**
 顶点缓冲对象：Vertex Buffer Object，VBO
 索引缓冲对象：Element Buffer Object，EBO或Index Buffer Object，IBO
 OpenGL 着色器语言：OpenGL Shading Language, GLSL
 标准化设备坐标(Normalized Device Coordinates, NDC)
 */
/**
 1.法线的含义
 3.ambientColor diffuseColor 的含义
 5.使用buffer相对于立方体形式的优势
 8.kEAGLRenderingAPIOpenGLES3、kEAGLRenderingAPIOpenGLES2都是哪些版本
 9.glEnable()GL_DEPTH_TEST、GL_CULL_FACE含义、作用

 建模
 */
/*
 2.modelviewMatrix 与lookAt的区别
 7.IBO及EBO的定义
 */

typedef struct{
    GLfloat position[3];
    GLfloat texturePosition[2];
} Vertex;

@interface PlanetViewController ()

@property (nonatomic,strong)GLKBaseEffect *effect;
@property(nonatomic,assign)GLint degreeX;
@property(nonatomic,assign)GLint degreeY;

@end

@implementation PlanetViewController {

    Vertex *_circleVertex;
    GLuint * _vertextIndex;
    GLKMatrix4 _modelMatrix;

    GLuint _bufferVBO;
    GLuint _bufferIndexEBO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView * glView = (GLKView *)self.view;

    //每个上下文都针对特定版本的OpenGL ES
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if (!context) {
        NSLog(@"context创建失败");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"设置当前context失败");
        return;
    }
    glView.context = context;

    self.effect = [[GLKBaseEffect alloc] init];
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    [self setupLighting];
    [self setupTexture];
    [self setupBufferVBOAndEBO];

    //设置背景色
    glClearColor(0.7, 0.7, 0.7, 1.0);

    // 设置视角和物体的矩阵变换
    self.effect.transform.modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -3);
    self.effect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), self.view.frame.size.width / self.view.frame.size.height, 0.1f, 10.0f);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];

    self.degreeX += currentPoint.x - previousPoint.x;
    self.degreeY += currentPoint.y - previousPoint.y;
}

/**
 设置纹理
 */
- (void)setupTexture{
    // 加载纹理图片
    //GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft: @(1)};
    CGImageRef image = [UIImage imageNamed:@"cat"].CGImage;
    GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:image options:options error:nil];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
    self.effect.texture2d0.target = textureInfo.target;
}

/**
 设置光照
 */
- (void)setupLighting{
    self.effect.light0.enabled = GL_TRUE;//是否开启光照
    self.effect.light0.position = GLKVector4Make(1.0, 0.8, 0.8, 0.0);//光源位置(世界坐标系)
    self.effect.light0.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);//材质的环境色。(环境光照)
    self.effect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);//漫反射颜色(漫反射光照)

}

/**
 设置顶点缓存VBO
 */
- (void)setupBufferVBOAndEBO {

    //获取球的顶点和索引
    _circleVertex = [self getBallCircleVertexWithNum:kCount];
    _vertextIndex = [self getBallVertexIndexWithNum:kCount];

    //设置VBO
    ///1.创建VBO对象
    glGenBuffers(1, &_bufferVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _bufferVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * (kCount + 1) * (kCount / 2 + 1), _circleVertex, GL_STATIC_DRAW);

    //设置_bufferIndexEBO
    glGenBuffers(1, &_bufferIndexEBO);//顶点索引缓冲对象：IBO/_bufferIndexEBO
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufferIndexEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * kCount * (kCount + 1), _vertextIndex, GL_STATIC_DRAW);

    //链接顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)NULL);

    // 设置法线
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)NULL);

    // 设置纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLfloat *)NULL +3);

    // 释放顶点数据
    free(_circleVertex);
    free(_vertextIndex);
}

- (void)update{
    _modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -3);
    _modelMatrix = GLKMatrix4RotateX(_modelMatrix, GLKMathDegreesToRadians(self.degreeY % 360));
    _modelMatrix = GLKMatrix4RotateY(_modelMatrix, GLKMathDegreesToRadians(self.degreeX % 360));
    self.effect.transform.modelviewMatrix = _modelMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    //1.清楚缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //2.准备渲染
    [self.effect prepareToDraw];

    //3.绘制一个球 图元、顶点数量、元素类型、索引数组指针
    glDrawElements(GL_TRIANGLE_STRIP, kCount * (kCount + 1), GL_UNSIGNED_INT, 0);

}

/// 绘制一个球的顶点
- (Vertex *)getBallCircleVertexWithNum:(GLint) num {
    if (num % 2 == 1) {
        return 0;
    }
    GLfloat delta = 2 * M_PI / num; // 分割的份数
    GLfloat ballRaduis = 0.8; // 球的半径
    //顶点
    GLfloat pointZ;
    GLfloat pointX;
    GLfloat pointY;
    //纹理
    GLfloat textureY;
    GLfloat textureX;

    GLfloat textureYdelta = 1.0 / (num / 2);
    GLfloat textureXdelta = 1.0 / num;

    GLint layerNum = num / 2.0 + 1; // 层数(顶点层)
    GLint perLayerNum = num + 1; // 要让点再加到起点所以num + 1

    Vertex * cirleVertex = malloc(sizeof(Vertex) * perLayerNum * layerNum);
    memset(cirleVertex, 0x00, sizeof(Vertex) * perLayerNum * layerNum);

    // 层数
    for (int i = 0; i < layerNum; i++) {
        // 每层的高度(即pointY)，为负数让其从下向上创建
        pointY = -ballRaduis * cos(delta * i);
        // 每层的半径
        GLfloat layerRaduis = ballRaduis * sin(delta * i);
        // 每层圆的点,
        for (int j = 0; j < perLayerNum; j++) {
            // 计算
            pointX = layerRaduis * cos(delta * j);
            pointZ = layerRaduis * sin(delta * j);
            textureX = textureXdelta * j;
            textureY = textureYdelta * i;
            cirleVertex[i * perLayerNum + j] = (Vertex){pointX, pointY, pointZ, textureX, textureY};
        }
    }
    return cirleVertex;
}

 ///顶点索引
- (GLuint *)getBallVertexIndexWithNum:(GLint)num {
    // 每层要多原点两次
    GLint sizeNum = sizeof(GLuint) * (num + 1) * (num + 1);
    GLuint * ballVertexIndex = malloc(sizeNum);
    memset(ballVertexIndex, 0x00, sizeNum);
    GLint layerNum = num / 2 + 1;
    GLint perLayerNum = num + 1; // 要让点再加到起点所以num + 1

    for (int i = 0; i < layerNum; i++) {
        if (i + 1 < layerNum) {
            for (int j = 0; j < perLayerNum; j++) {
                // i * perLayerNum * 2每层的下标是原来的2倍
                ballVertexIndex[(i * perLayerNum * 2) + (j * 2)] = i * perLayerNum + j;
                // 后一层数据
                ballVertexIndex[(i * perLayerNum * 2) + (j * 2 + 1)] = (i + 1) * perLayerNum + j;
            }
        } else {
            for (int j = 0; j < perLayerNum; j++) {
                // 后最一层数据单独处理
                ballVertexIndex[i * perLayerNum * 2 + j] = i * perLayerNum + j;
            }
        }
    }
    return ballVertexIndex;
}

@end
