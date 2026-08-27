import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class ReferralService extends ResourceService {
	ReferralService(ApiClient api) : super(api, '/referrals/me');
}
