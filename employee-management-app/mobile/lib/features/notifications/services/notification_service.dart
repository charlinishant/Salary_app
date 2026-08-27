import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class NotificationService extends ResourceService {
	NotificationService(ApiClient api) : super(api, '/notifications');
}
