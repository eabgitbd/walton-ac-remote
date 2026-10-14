import '../models/ac_state.dart';

abstract class IrProtocol {
  int get carrierFrequency;
  List<int> encode(AcState state);
}
