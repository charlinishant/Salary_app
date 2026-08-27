import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class SalaryService extends ResourceService {
	SalaryService(ApiClient api) : super(api, '/payslips');
}
