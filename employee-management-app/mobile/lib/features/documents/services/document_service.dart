import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class DocumentService extends ResourceService {
	DocumentService(ApiClient api) : super(api, '/documents');
}
