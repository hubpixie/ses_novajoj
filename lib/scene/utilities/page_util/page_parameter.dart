enum TopDetailParamKeys { itemInfo }

class PageParameter<T> {
  PageParameter({required this.key, this.value});

  final String key;
  T? value;
}
