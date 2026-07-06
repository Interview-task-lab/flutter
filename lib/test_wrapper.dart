import 'package:flutter/material.dart';

/// Web ve React tarafındaki `data-testid="..."` yapısına benzer bir
/// kullanım sağlamak için oluşturulmuş özel bir sarmalayıcı (wrapper) widget.
/// Bu sayede test araçları (Integration Test, Appium vb.) `dataTestId`
/// değeri ile bu widget'ı kolayca bulabilir.
class TestWrapper extends StatelessWidget {
  final String dataTestId;
  final Widget child;

  const TestWrapper({
    Key? key,
    required this.dataTestId,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: dataTestId,
      child: KeyedSubtree(
        key: Key(dataTestId),
        child: child,
      ),
    );
  }
}
