import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class AnnouncementService extends ResourceService {
	AnnouncementService(ApiClient api) : super(api, '/announcements');
}
