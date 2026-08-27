import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class HolidayService extends ResourceService {
	HolidayService(ApiClient api) : super(api, '/holidays');
}
