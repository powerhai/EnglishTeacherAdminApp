 
import 'package:dio_http_cache/dio_http_cache.dart';

class DioHelper {  
 static Map<String,DioCacheManager> _managers = new Map<String,DioCacheManager>(); 
  static DioCacheManager getCacheManager({String baseUrl = "system"}) {
    if(!_managers.containsKey(baseUrl)) 
    {
      var mg = new DioCacheManager(CacheConfig(baseUrl: baseUrl ));
      _managers[baseUrl] = mg;
    }
    return _managers[baseUrl]; 
  } 
  
}