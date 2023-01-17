import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'GOOGLE_SERVICE_API_KEY', obfuscate: true)
  static final googleServiceApiKey = _Env.googleServiceApiKey;

}