import 'package:flutter/material.dart';

import '../providers/app_icon_provider.dart';

/// 启动页"绘制 logo"动画组件
///
/// 入场时用主题色细线沿轮廓逐段描出 logo,随后各色块依次淡入、
/// 描边线淡出,终态与 assets 中的 SVG 完全一致(直接用 CustomPainter
/// 复刻几何,无需切换回 SVG)。绘制完成后保持光晕缓慢呼吸。
class PreheatLogo extends StatefulWidget {
  final AppIconStyle style;
  final double size;

  const PreheatLogo({super.key, required this.style, this.size = 108});

  @override
  State<PreheatLogo> createState() => _PreheatLogoState();
}

class _PreheatLogoState extends State<PreheatLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    duration: const Duration(milliseconds: 2200),
    vsync: this,
  );
  late final AnimationController _glow = AnimationController(
    duration: const Duration(milliseconds: 2400),
    vsync: this,
  );

  List<_LogoShape> _shapes = const [];
  Brightness? _brightness;

  @override
  void initState() {
    super.initState();
    _entry
      ..addStatusListener((status) {
        // 绘制完成后才开始光晕呼吸
        if (status == AnimationStatus.completed) {
          _glow.repeat(reverse: true);
        }
      })
      ..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_brightness != brightness) {
      _brightness = brightness;
      _rebuildShapes();
    }
  }

  @override
  void didUpdateWidget(covariant PreheatLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style) {
      _rebuildShapes();
    }
  }

  void _rebuildShapes() {
    _shapes = widget.style == AppIconStyle.modern
        ? _buildModernShapes(_brightness ?? Brightness.light)
        : _buildClassicShapes();
  }

  @override
  void dispose() {
    _entry.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const viewSize = 1024.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _glow]),
      builder: (context, _) {
        // 光晕随填充出现而渐亮,之后跟随 _glow 缓慢呼吸
        final glowIn = _segment(_entry.value, 0.45, 1.0, Curves.easeIn);
        final breathe = Curves.easeInOutSine.transform(_glow.value);
        final glowAlpha = glowIn * (0.12 + 0.10 * breathe);
        final glowBlur = 36.0 + 16.0 * breathe;

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: glowAlpha),
                blurRadius: glowBlur,
              ),
            ],
          ),
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _LogoPainter(
                shapes: _shapes,
                t: _entry.value,
                strokeColor: colorScheme.primary,
                viewSize: viewSize,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 将整体进度 [t] 映射到 [start, end] 区间内的局部进度并应用曲线
double _segment(double t, double start, double end,
    [Curve curve = Curves.easeInOutCubic]) {
  return curve.transform(((t - start) / (end - start)).clamp(0.0, 1.0));
}

/// logo 的一个组成形状:填充路径 + 可选的描边路径
class _LogoShape {
  final Path fillPath;
  final Color fill;

  /// 描边动画走的路径,可与填充轮廓不同
  final Path? strokePath;

  final double strokeStart;
  final double strokeEnd;
  final double fillStart;
  final double fillEnd;

  const _LogoShape({
    required this.fillPath,
    required this.fill,
    this.strokePath,
    this.strokeStart = 0,
    this.strokeEnd = 1,
    required this.fillStart,
    required this.fillEnd,
  });
}

class _LogoPainter extends CustomPainter {
  final List<_LogoShape> shapes;
  final double t;
  final Color strokeColor;

  /// viewBox 边长,绘制时统一缩放到组件尺寸
  final double viewSize;

  /// 描边线在该进度后整体淡出
  static const double _strokeFadeStart = 0.84;

  const _LogoPainter({
    required this.shapes,
    required this.t,
    required this.strokeColor,
    required this.viewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / viewSize;
    canvas.save();
    canvas.scale(scale);

    for (final shape in shapes) {
      final fillT = _segment(t, shape.fillStart, shape.fillEnd, Curves.easeInOut);
      if (fillT <= 0) continue;
      canvas.drawPath(
        shape.fillPath,
        Paint()..color = shape.fill.withValues(alpha: fillT),
      );
    }

    final strokeAlpha = 1.0 - _segment(t, _strokeFadeStart, 1.0, Curves.easeOut);
    if (strokeAlpha > 0) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 / scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = strokeColor.withValues(alpha: strokeAlpha);
      for (final shape in shapes) {
        final strokePath = shape.strokePath;
        if (strokePath == null) continue;
        final strokeT =
            _segment(t, shape.strokeStart, shape.strokeEnd, Curves.easeInOutCubic);
        if (strokeT <= 0) continue;
        for (final metric in strokePath.computeMetrics()) {
          canvas.drawPath(
            metric.extractPath(0, metric.length * strokeT),
            strokePaint,
          );
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.shapes != shapes ||
        oldDelegate.strokeColor != strokeColor;
  }
}

/// idcflare 品牌红
const _brandRed = Color(0xFFA81818);

/// 经典 logo(assets/logo.svg):红圆 + 白色 IF. 字标,viewBox 1024
List<_LogoShape> _buildClassicShapes() {
  return _buildIfShapes(
    circleColor: _brandRed,
    letterColor: const Color(0xFFFFFFFF),
  );
}

/// modern logo(assets/logo_modern*.svg):深浅中性底圆 + 红色 IF. 字标,
/// 几何与经典款一致,viewBox 1024
List<_LogoShape> _buildModernShapes(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return _buildIfShapes(
    circleColor: dark ? const Color(0xFF1C1C1E) : const Color(0xFFF0F0F3),
    letterColor: _brandRed,
  );
}

/// IF. 字标几何(与 assets/logo*.svg 相同坐标):
/// 底圆 + I 柱 + F(顶臂长、中臂短)+ 六边形句点
List<_LogoShape> _buildIfShapes({
  required Color circleColor,
  required Color letterColor,
}) {
  final circle = Path()
    ..addOval(Rect.fromCircle(center: const Offset(512, 512), radius: 448));

  final iBar = Path()..addRect(const Rect.fromLTRB(252, 304, 377, 720));

  final f = Path()
    ..moveTo(465, 304)
    ..lineTo(772, 304)
    ..lineTo(772, 393)
    ..lineTo(590, 393)
    ..lineTo(590, 466)
    ..lineTo(745, 466)
    ..lineTo(745, 550)
    ..lineTo(590, 550)
    ..lineTo(590, 720)
    ..lineTo(465, 720)
    ..close();

  final hexDot = Path()
    ..moveTo(721.5, 620)
    ..lineTo(764.5, 645)
    ..lineTo(764.5, 695)
    ..lineTo(721.5, 720)
    ..lineTo(678.5, 695)
    ..lineTo(678.5, 645)
    ..close();

  _LogoShape shape(
    Path path,
    Color fill, {
    required double strokeStart,
    required double strokeEnd,
    required double fillStart,
    required double fillEnd,
  }) {
    return _LogoShape(
      fillPath: path,
      fill: fill,
      strokePath: path,
      strokeStart: strokeStart,
      strokeEnd: strokeEnd,
      fillStart: fillStart,
      fillEnd: fillEnd,
    );
  }

  return [
    shape(circle, circleColor,
        strokeStart: 0.0, strokeEnd: 0.45, fillStart: 0.48, fillEnd: 0.68),
    shape(iBar, letterColor,
        strokeStart: 0.20, strokeEnd: 0.38, fillStart: 0.56, fillEnd: 0.76),
    shape(f, letterColor,
        strokeStart: 0.30, strokeEnd: 0.54, fillStart: 0.62, fillEnd: 0.82),
    shape(hexDot, letterColor,
        strokeStart: 0.44, strokeEnd: 0.58, fillStart: 0.66, fillEnd: 0.86),
  ];
}
