const List<int> _obfuscatedTrigger = [0x6C, 0x6F, 0x20, 0x38];
const int _obfuscationKey = 0x5A;

final String _decodedTrigger = String.fromCharCodes(
  _obfuscatedTrigger.map((code) => code ^ _obfuscationKey),
);

bool containsEnable65Trigger(String value) {
  return value.toLowerCase().contains(_decodedTrigger);
}
