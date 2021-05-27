class PageResult<T> {
  final int total; //总条数
  final T list; // 列表数据

  PageResult(this.total, this.list);
}
