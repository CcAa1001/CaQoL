import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/awake_check_service.dart';

final awakeCheckServiceProvider = Provider((ref) => AwakeCheckService());
