class BaseResult<T> {
  final bool isSuccess; //是否成功
  final int code; // 返回码
  final String msg; //返回信息
  final T data; // 返回数据

  BaseResult(this.isSuccess, this.code, this.msg, this.data);

  static BaseResult success<T>(result) {
    return new BaseResult<T>(true, 200, '操作成功', result);
  }

  static BaseResult error<T>({int code = 400, String msg = '操作失败'}) {
    return new BaseResult<T>(false, code, msg, null);
  }
}
