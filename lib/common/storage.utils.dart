import '../exceptions/storage_not_found.exception.dart';
import '../main.dart';

class StorageUtils {
  static Future<String> getAuthToken() async {
    final token = await storage.read(key: "token");
    if (token == null) {
      throw StorageNotFoundException('No JWT token found');
    }
    return token;
  }

  static Future<void> saveUserAuthToken(String token) async {
    await storage.write(key: "token", value: token);
  }
}
