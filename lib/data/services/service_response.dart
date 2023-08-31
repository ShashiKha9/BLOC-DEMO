abstract class ServiceResponse {}

abstract class ServiceDataResponse<TResult> extends ServiceResponse {}

class SuccessDataResponse<TResult> extends ServiceDataResponse<TResult> {
  final TResult result;

  SuccessDataResponse(this.result);
}

class FailureDataResponse<TResult> extends ServiceDataResponse<TResult> {
  final String message;

  FailureDataResponse(this.message);
}

class SuccessResponse extends ServiceResponse {}

class FailResponse extends ServiceResponse {
  final String message;
  FailResponse(this.message);
}
