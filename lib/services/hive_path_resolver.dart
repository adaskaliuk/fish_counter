export 'hive_path_resolver_stub.dart'
    if (dart.library.io) 'hive_path_resolver_io.dart'
    if (dart.library.js_interop) 'hive_path_resolver_web.dart';
