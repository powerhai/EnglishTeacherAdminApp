import 'package:get_it/get_it.dart';

import 'book_service.dart';
import 'sentence_service.dart';
import 'student_service.dart';
import 'text_service.dart';
import 'translate_service.dart';
import 'book_family_service.dart';
import 'yaml_config_service.dart';

void registerService() {
  GetIt.instance.registerSingletonAsync<ConfigService>(
      () => ConfigService().init(),
      signalsReady: false);

  GetIt.instance.registerSingletonAsync<BookPublisherService>(
      () => BookPublisherService().init());

  GetIt.instance
      .registerSingletonAsync<BookService>(() => BookService().init());

  GetIt.instance
      .registerSingletonAsync<TextService>(() => TextService().init());

  GetIt.instance
      .registerSingletonAsync<SentenceService>(() => SentenceService().init());


  GetIt.instance.registerLazySingletonAsync<BaiduSentenceTranslateService>(
      () => BaiduSentenceTranslateService().init());

  GetIt.instance.registerLazySingleton<StudentService>(() => StudentService());
 



}
