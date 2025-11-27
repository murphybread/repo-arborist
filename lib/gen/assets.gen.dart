// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/playground
  $AssetsImagesPlaygroundGen get playground =>
      const $AssetsImagesPlaygroundGen();

  /// Directory path: assets/images/trees
  $AssetsImagesTreesGen get trees => const $AssetsImagesTreesGen();
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/en.json
  String get en => 'assets/translations/en.json';

  /// File path: assets/translations/ko.json
  String get ko => 'assets/translations/ko.json';

  /// List of all assets
  List<String> get values => [en, ko];
}

class $AssetsImagesPlaygroundGen {
  const $AssetsImagesPlaygroundGen();

  /// File path: assets/images/playground/tree_glow-56586a.png
  AssetGenImage get treeGlow56586a =>
      const AssetGenImage('assets/images/playground/tree_glow-56586a.png');

  /// List of all assets
  List<AssetGenImage> get values => [treeGlow56586a];
}

class $AssetsImagesTreesGen {
  const $AssetsImagesTreesGen();

  /// File path: assets/images/trees/bloom_blue.svg
  SvgGenImage get bloomBlue =>
      const SvgGenImage('assets/images/trees/bloom_blue.svg');

  /// File path: assets/images/trees/bloom_orange.svg
  SvgGenImage get bloomOrange =>
      const SvgGenImage('assets/images/trees/bloom_orange.svg');

  /// File path: assets/images/trees/bloom_orange_dot.png
  AssetGenImage get bloomOrangeDot =>
      const AssetGenImage('assets/images/trees/bloom_orange_dot.png');

  /// File path: assets/images/trees/bloom_pink.svg
  SvgGenImage get bloomPink =>
      const SvgGenImage('assets/images/trees/bloom_pink.svg');

  /// File path: assets/images/trees/bloom_purple.svg
  SvgGenImage get bloomPurple =>
      const SvgGenImage('assets/images/trees/bloom_purple.svg');

  /// File path: assets/images/trees/bloom_purple_dot.png
  AssetGenImage get bloomPurpleDot =>
      const AssetGenImage('assets/images/trees/bloom_purple_dot.png');

  /// File path: assets/images/trees/bloom_yellow.svg
  SvgGenImage get bloomYellow =>
      const SvgGenImage('assets/images/trees/bloom_yellow.svg');

  /// File path: assets/images/trees/cactus_bloom.svg
  SvgGenImage get cactusBloom =>
      const SvgGenImage('assets/images/trees/cactus_bloom.svg');

  /// File path: assets/images/trees/cactus_sprout.svg
  SvgGenImage get cactusSprout =>
      const SvgGenImage('assets/images/trees/cactus_sprout.svg');

  /// File path: assets/images/trees/cactus_tree.svg
  SvgGenImage get cactusTree =>
      const SvgGenImage('assets/images/trees/cactus_tree.svg');

  /// File path: assets/images/trees/cherry blossom.png
  AssetGenImage get cherryBlossom =>
      const AssetGenImage('assets/images/trees/cherry blossom.png');

  /// File path: assets/images/trees/clean_background.py
  String get cleanBackground => 'assets/images/trees/clean_background.py';

  /// File path: assets/images/trees/generate_tree_dot.png
  AssetGenImage get generateTreeDot =>
      const AssetGenImage('assets/images/trees/generate_tree_dot.png');

  /// File path: assets/images/trees/maple.png
  AssetGenImage get maple =>
      const AssetGenImage('assets/images/trees/maple.png');

  /// File path: assets/images/trees/sprout.svg
  SvgGenImage get sprout => const SvgGenImage('assets/images/trees/sprout.svg');

  /// File path: assets/images/trees/sprout_dot.png
  AssetGenImage get sproutDot =>
      const AssetGenImage('assets/images/trees/sprout_dot.png');

  /// File path: assets/images/trees/tree_green.svg
  SvgGenImage get treeGreen =>
      const SvgGenImage('assets/images/trees/tree_green.svg');

  /// File path: assets/images/trees/tree_red.svg
  SvgGenImage get treeRed =>
      const SvgGenImage('assets/images/trees/tree_red.svg');

  /// List of all assets
  List<dynamic> get values => [
    bloomBlue,
    bloomOrange,
    bloomOrangeDot,
    bloomPink,
    bloomPurple,
    bloomPurpleDot,
    bloomYellow,
    cactusBloom,
    cactusSprout,
    cactusTree,
    cherryBlossom,
    cleanBackground,
    generateTreeDot,
    maple,
    sprout,
    sproutDot,
    treeGreen,
    treeRed,
  ];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const SvgGenImage blueberry = SvgGenImage('assets/blueberry.svg');
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();

  /// List of all assets
  static List<dynamic> get values => [aEnv, blueberry];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
