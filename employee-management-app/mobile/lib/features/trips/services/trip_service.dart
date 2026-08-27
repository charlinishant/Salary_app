import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class TripService extends ResourceService {
	TripService(ApiClient api) : super(api, '/trips');
}
