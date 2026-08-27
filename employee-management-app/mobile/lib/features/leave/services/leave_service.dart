import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class LeaveService extends ResourceService {
	LeaveService(ApiClient api) : super(api, '/leaves');
}
