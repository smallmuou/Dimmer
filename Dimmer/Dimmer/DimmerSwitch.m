/*!
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
 * @File:       DimmerSwitch.h
 * @Abstract:   调光开关
 * @History:
 
 -2013-09-12 创建 by xuwf
 */

#import "DimmerSwitch.h"

#define START_DEGREES                   (-60)   /* 开始度数 */
#define END_DEGREES                     (240)   /* 结束度数 */
#define DEGREES_STEP_MAX                (20)    /* 跳变阈值，反正大跳变 */
#define DEGREES_STEP_MIN                (1)     /* 事件跳变最小阈值 */

#define DEGREES_TO_RADIANS(_degrees)    ((M_PI * (_degrees))/180)
#define RADIANS_TO_DEGREES(_radians)    ((_radians)*180)/M_PI

@interface DimmerSwitch () {
    UIImageView* _backgroudView;/* 背景 */
    UIButton* _button;          /* 按钮 */
    UIImageView* _dimmerView;   /* 调光 */
    UILabel* _tipLalel;         /* 提示 */
    
    UIImage* _dimmerImage;
    
    CGPoint _recordPoint;       /* 记录点 */
    CGPoint _centerPoint;       /* 中心点 */
    CGFloat _radius;            /* 半径 */
    CGFloat _currentDegrees;    /* 当前度数 */
    CGFloat _recordDegrees;     /* 记录度数(打开开关后能恢复到上次位置) */
}

@end

@implementation DimmerSwitch
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /* UI */
        [self setBackgroundColor:[UIColor clearColor]];
        
        _backgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DimmerSwitch.bundle/bg"]];
        [self addSubview:_backgroudView];
        self.bounds = _backgroudView.bounds;
        _centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        _dimmerImage = [UIImage imageNamed:@"DimmerSwitch.bundle/dimmer"];
        _dimmerView = [[UIImageView alloc] initWithImage:_dimmerImage];
        [self addSubview:_dimmerView];
        
        CGSize switchSize = [[UIImage imageNamed:@"DimmerSwitch.bundle/switch_n"] size];
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, switchSize.width, switchSize.height)];
        [_button setImage:[UIImage imageNamed:@"DimmerSwitch.bundle/switch_n"] forState:UIControlStateNormal];
        [_button setImage:[UIImage imageNamed:@"DimmerSwitch.bundle/switch_n"] forState:UIControlStateHighlighted];
        [_button setImage:[UIImage imageNamed:@"DimmerSwitch.bundle/switch_h"] forState:UIControlStateSelected];
        [_button setSelected:_on];

        _button.center = _centerPoint;
        [self addSubview:_button];
        
        [_button addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _tipLalel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [_tipLalel setBackgroundColor:[UIColor clearColor]];
        [_tipLalel setFont:[UIFont systemFontOfSize:14]];
        [_tipLalel setTextColor:[UIColor whiteColor]];
        [self addSubview:_tipLalel];
        
        /* 数据 */
        _radius = self.bounds.size.width/2;
        _currentDegrees = _on ? START_DEGREES : END_DEGREES;
        _recordDegrees = _currentDegrees;        
    }
    return self;
}

- (BOOL)on {
    return _on;
}

- (void)setOn:(BOOL)on {
    _on = !_on;
    [_button setSelected:_on];
}

- (CGFloat)progress {
    CGFloat progress =  (END_DEGREES - _currentDegrees)/(END_DEGREES - START_DEGREES);
    progress = MAX(0.0, progress);
    progress = MIN(1.0, progress);
    return progress;
}

- (void)updateView {
    _recordDegrees = _currentDegrees;
    _on = (_currentDegrees < END_DEGREES);
    [_button setSelected:_on];
    
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
    _currentDegrees = END_DEGREES - _progress*(END_DEGREES - START_DEGREES);
    [self updateView];
}

- (void)onButtonPressed:(id)sender {
    _on = !_on;
    [_button setSelected:_on];
    
    if (_on) {
        _currentDegrees = (_recordDegrees == END_DEGREES) ? START_DEGREES : _recordDegrees;
    } else {
        _recordDegrees = _currentDegrees;
        _currentDegrees = END_DEGREES;
    }
    [self setNeedsDisplay];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _recordPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    
    CGFloat degree = [self degreesForPointA:_recordPoint toPoint:currentPoint];
    /* 变化太大不更新 */
    _currentDegrees = (fabsf(degree) > DEGREES_STEP_MAX) ? _currentDegrees : (_currentDegrees+degree);

    _currentDegrees = MAX(_currentDegrees, START_DEGREES);
    _currentDegrees = MIN(_currentDegrees,END_DEGREES);

    /* 大于DEGREES_STEP_MIN才触发事件 */
    if (fabsf(degree) > DEGREES_STEP_MIN && (_recordDegrees != _currentDegrees)) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    _recordDegrees = _currentDegrees;
    _recordPoint = currentPoint;
    
    [self updateView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
}

/* 相对于中心点的度数，从-90<=degrees<270 */
- (CGFloat)degreesForPoint:(CGPoint)point {
    CGFloat x = point.x - _centerPoint.x;
    CGFloat y = - (point.y - _centerPoint.y);   /* view坐标系y坐标朝下，因此取反 */

    if (0 == x) return (y > 0) ? 90 : -90;
    
    double ridians = atan(y/x);
    CGFloat degrees = RADIANS_TO_DEGREES(ridians);
    if (x < 0) degrees += 180;
    return degrees;
}

- (CGFloat)degreesForPointA:(CGPoint)pointA toPoint:(CGPoint)pointB {
    CGFloat degreesA = [self degreesForPoint:pointA];
    CGFloat degreesB = [self degreesForPoint:pointB];
    return degreesB - degreesA;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 8, 4 * self.bounds.size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
    
    CGContextAddArc(context, _centerPoint.x, _centerPoint.y, _radius, DEGREES_TO_RADIANS(END_DEGREES), DEGREES_TO_RADIANS(_currentDegrees), YES);
    CGContextAddArc(context, _centerPoint.x, _centerPoint.y, 0, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(0), YES);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, self.bounds, _dimmerImage.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);

    [_dimmerView setImage:newImage];
}

@end
