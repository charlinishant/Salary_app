import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class AttendanceAlarmService extends ResourceService {
	AttendanceAlarmService(ApiClient api) : super(api, '/notifications');
}
