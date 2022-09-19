import 'package:ses_novajoj/foundation/data/user_types.dart';

class CitySelectItemRes {
  Map<String, List<double>>? locations;
  List<CityInfo>? cityInfos;

  CitySelectItemRes({required this.cityInfos, this.locations});

  Map<String, List<double>>? _locations;
  List<CityInfo>? _cityInfos;

  CitySelectItemRes.fromJson(dynamic jsonList) {
    _locations ??= {};
    _cityInfos = () {
      final parsed = jsonList as List?;
      if (parsed != null) {
        final list = parsed.map((elem) {
          // CityInfo
          CityInfo cityInfo = CityInfo();
          _findLocalNameAndEtc(cityInfo,
              nameDic: elem['local_names'],
              countryCode: elem['country'],
              defaultName: elem['name']);
          cityInfo.name = elem['name'];
          cityInfo.state = elem['state'] ?? elem['name'];
          cityInfo.countryCode = elem['country'];

          // LocationInfo
          _locations?[cityInfo.toCityKey()] = [elem['lat'], elem['lon']];

          return cityInfo;
        }).toList();

        final keys = list.map((elem) => elem.toCityKey()).toSet();

        // remove duplicated data
        // set result
        return list.where((elem) => keys.remove(elem.toCityKey())).toList();
      } else {
        return <CityInfo>[];
      }
    }();

    cityInfos = _cityInfos;
    locations = _locations;
  }

  void _findLocalNameAndEtc(CityInfo cityInfo,
      {Map<String, dynamic>? nameDic,
      String countryCode = '',
      String defaultName = ''}) {
    if (nameDic == null) {
      cityInfo.nameDesc = defaultName;
      cityInfo.langCode = 'en';
      return;
    }

    String nameDesc = defaultName;
    String langCode = 'en';
    for (var elem in ['zh', 'ja', 'fr', 'pt', 'ru', 'ko']) {
      if (elem == 'zh' && ['CN', 'TW'].contains(countryCode)) {
        nameDesc = nameDic[elem];
        langCode = 'zh';
      } else if (elem == 'ja' && countryCode == 'JP') {
        nameDesc = nameDic[elem];
        langCode = 'ja';
      } else if (elem == 'fr' && countryCode == 'FR') {
        nameDesc = nameDic[elem];
        langCode = 'fr';
      } else if (elem == 'pt' && ['BR', 'PT'].contains(countryCode)) {
        nameDesc = nameDic[elem];
        langCode = 'pt';
      } else if (elem == 'ru' && countryCode == 'RU') {
        nameDesc = nameDic[elem];
        langCode = 'ru';
      } else if (elem == 'ko' && countryCode == 'KR') {
        nameDesc = nameDic[elem];
        langCode = 'ko';
      }
    }
    cityInfo.nameDesc = nameDesc;
    cityInfo.langCode = langCode;
    return;
  }
}
