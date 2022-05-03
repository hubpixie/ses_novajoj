enum TopDetailParamKeys { source, appBarTitle, itemInfo }
enum ThreadDetailParamKeys { appBarTitle, itemInfo }
enum BbsDetailParamKeys { appBarTitle, itemInfo }
enum BbsSelectListParamKeys { appBarTitle, targetUrl }

class PageParameter<T> {
  PageParameter({required this.key, this.value});

  final String key;
  T? value;
}
