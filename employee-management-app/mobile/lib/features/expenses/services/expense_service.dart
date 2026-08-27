import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class ExpenseService extends ResourceService {
	ExpenseService(ApiClient api) : super(api, '/expenses');
}
