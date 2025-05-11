import 'package:fit_me/core/common/base_message.dart';

abstract class BaseRuntime<M extends BaseMessage> {
  void dispatch(M message);
}
