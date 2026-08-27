import '../../common/resource_service.dart';
import '../../../core/network/api_client.dart';

class NotesService extends ResourceService {
	NotesService(ApiClient api) : super(api, '/notes');
}
