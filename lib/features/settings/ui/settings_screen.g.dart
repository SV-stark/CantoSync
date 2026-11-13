// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'd69e13be1520e27ae1c9827c4d77156ed26551a6';

@ProviderFor(audioOutputDevices)
final audioOutputDevicesProvider = AudioOutputDevicesProvider._();

final class AudioOutputDevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AudioOutputDevice>>,
          List<AudioOutputDevice>,
          FutureOr<List<AudioOutputDevice>>
        >
    with
        $FutureModifier<List<AudioOutputDevice>>,
        $FutureProvider<List<AudioOutputDevice>> {
  AudioOutputDevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioOutputDevicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioOutputDevicesHash();

  @$internal
  @override
  $FutureProviderElement<List<AudioOutputDevice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AudioOutputDevice>> create(Ref ref) {
    return audioOutputDevices(ref);
  }
}

String _$audioOutputDevicesHash() =>
    r'11262fa4d935bb501886a040f71c9e416218d7dd';

@ProviderFor(packageInfo)
final packageInfoProvider = PackageInfoProvider._();

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  PackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'907ba5b02ed285ba1e951e58a932554b0a8da650';
