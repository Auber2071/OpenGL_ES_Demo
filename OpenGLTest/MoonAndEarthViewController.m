//
//  MoonAndEarthViewController.m
//  OpenGLTest
//
//  Created by Edward on 2022/2/10.
//  Copyright © 2024 Edward. All rights reserved.
//

#import "MoonAndEarthViewController.h"
#import "MoonAndEarthVertexAttribArrayBuffer.h"
#import "sphere.h"

@interface MoonAndEarthViewController ()
@property (nonatomic , strong) EAGLContext* mContext;

@property (nonatomic, strong) MoonAndEarthVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic, strong) MoonAndEarthVertexAttribArrayBuffer *vertexNormalBuffer;
@property (nonatomic, strong) MoonAndEarthVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKTextureInfo *earthTextureInfo;
@property (nonatomic, strong) GLKTextureInfo *moonTextureInfo;
@property (nonatomic, assign) GLKMatrixStackRef modelviewMatrixStack;
@property (nonatomic, assign) GLfloat earthRotationAngleDegrees;
@property (nonatomic, assign) GLfloat moonRotationAngleDegrees;
@end

@implementation MoonAndEarthViewController

static const GLfloat  SceneEarthAxialTiltDeg = 23.5f;
static const GLfloat  SceneDaysPerMoonOrbit = 27.0f;
static const GLfloat  SceneMoonRadiusFractionOfEarth = 1.f;
static const GLfloat  SceneMoonDistanceFromEarth = 2.0;

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)viewDidLoad {
    //创建OpenGLES上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_mContext];
    
    //设置GLKView必要元素
    GLKView *view = (GLKView *)self.view;
    view.context = _mContext;
    
    //缓冲区的每个颜色通道使用8个bit（所以每个像素4个字节）
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //开启片元深度测试
    glEnable(GL_DEPTH_TEST);


    self.baseEffect = [[GLKBaseEffect alloc] init];
    [self configLight];
    
    GLfloat aspectRatio = (self.view.bounds.size.width) / (self.view.bounds.size.height);
    // 正射投影（视域为矩形）
    //self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-aspectRatio, aspectRatio, -1.0f, 1.0f, 1.0f, 120.0f);
    // 透视投影（视域为平截头体）
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeFrustum( -aspectRatio, aspectRatio, -1.0f, 1.0f, 2.0f, 120.0f);
    // 调整坐标系矩阵，生成合适的眼坐标系
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    //背景颜色
    glClearColor(0.7f, 0.7f, 0.7f, 1.0f);
    //顶点数组
    [self configVertexAttribArray];
}

- (void)configLight {
    //开启光照
    self.baseEffect.light0.enabled = GL_TRUE;
    //光源位置(世界坐标系)
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, 0.8f, 0.0f);
    //漫反射颜色(漫反射光照)，很少或者不会对物体的亮度产生影响，会着色被定向光线照射到的三角形。
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    //材质的环境色。(环境光照)，环境光来自于各个方向，因此会同等的增强所有几何图形的亮度。环境光的颜色会着色所有的结合图形。
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    //specularColor 镜面反射光保持默认，不透明白色。
}

// 准备顶点数据，以及纹理对象
- (void)configVertexAttribArray {
    // 创建矩阵堆
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    //顶点数据缓存
    self.vertexPositionBuffer = [[MoonAndEarthVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[MoonAndEarthVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[MoonAndEarthVertexAttribArrayBuffer alloc] initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat)) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    //告诉OpenGL该如何解析顶点数据
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    // 地球,月球纹理
    NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft: @(1)};
    CGImageRef earthImageRef = [UIImage imageNamed:@"Earth.jpg"].CGImage;
    self.earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef options:options error:nil];
    CGImageRef moonImageRef = [UIImage imageNamed:@"Moon.png"].CGImage;
    self.moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonImageRef options:options error:nil];
    // 将创建好的modelviewMatrixStack放到矩阵堆的顶部
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack, self.baseEffect.transform.modelviewMatrix);
    //初始化月亮在轨道的位置
    self.moonRotationAngleDegrees = -20.0f;
}

// 画地球
- (void)drawEarth {
    //重新定义纹理
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    //矩阵栈操作
    GLKMatrixStackPush(self.modelviewMatrixStack);
    // X轴倾角
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(SceneEarthAxialTiltDeg), 1.0f, 0.0f, 0.0f);
    // Y轴倾角
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(self.earthRotationAngleDegrees), 0.0f, 1.0f, 0.0f);
    // 重新设置坐标系矩阵
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    [MoonAndEarthVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];

    GLKMatrixStackPop(self.modelviewMatrixStack);
}

// 画月亮
- (void)drawMoon {
    //重新定义纹理
    self.baseEffect.texture2d0.name = self.moonTextureInfo.name;
    self.baseEffect.texture2d0.target = self.moonTextureInfo.target;
    //矩阵栈操作
    GLKMatrixStackPush(self.modelviewMatrixStack);
    // 先旋转坐标系，Z轴会发生对应的变化，再沿Z轴移动坐标系，最后缩小坐标系达到月球缩小的效果，则表现为围绕地球旋转的效果。
    GLKMatrixStackRotate(self.modelviewMatrixStack, GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 0.0f, 1.0f, 0.0f);
    GLKMatrixStackTranslate(self.modelviewMatrixStack, 0.0f, 0.0f, SceneMoonDistanceFromEarth);
    GLKMatrixStackScale(self.modelviewMatrixStack, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth);
    // 重新设置坐标系矩阵
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);

    [self.baseEffect prepareToDraw];
    [MoonAndEarthVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
}

// 场景数据变化
- (void)update {
    self.earthRotationAngleDegrees += 360.0f / 60.0f;
    self.moonRotationAngleDegrees += (360.0f / 60.0f) / SceneDaysPerMoonOrbit;
}

// 渲染场景代码
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    // GL_COLOR_BUFFER_BIT设置当前帧缓存的像素颜色缓存中的每个像素的值为glClearColor()函数设定的颜色。
    // GL_DEPTH_BUFFER_BIT设置当前帧缓存的深度缓存中的每个值都为最大深度值。
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self drawEarth];
    [self drawMoon];
}

@end
