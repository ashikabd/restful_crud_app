import 'package:get/get.dart';
import '../models/api_object.dart';
import '../services/api_service.dart';

class ObjectController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxList<ApiObject> objects = <ApiObject>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<ApiObject?> selectedObject = Rx<ApiObject?>(null);
  
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  List<ApiObject> _allObjects = [];

  @override
  void onInit() {
    super.onInit();
    fetchObjects();
  }

  Future<void> fetchObjects() async {
    try {
      isLoading.value = true;
      _allObjects = await _apiService.getObjects();
      _currentPage = 0;
      objects.clear();
      _loadPage();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load objects: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPage() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _allObjects.length);
    
    if (startIndex < _allObjects.length) {
      objects.addAll(_allObjects.sublist(startIndex, endIndex));
      _currentPage++;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || objects.length >= _allObjects.length) return;
    
    try {
      isLoadingMore.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      _loadPage();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchObjectById(String id) async {
    try {
      isLoading.value = true;
      selectedObject.value = await _apiService.getObjectById(id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load object details: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createObject(ApiObject object) async {
    try {
      isLoading.value = true;
      final newObject = await _apiService.createObject(object);
      
      objects.insert(0, newObject);
      _allObjects.insert(0, newObject);
      
      Get.snackbar(
        'Success',
        'Object created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create object: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateObject(String id, ApiObject object) async {
    try {
      isLoading.value = true;
      final updatedObject = await _apiService.updateObject(id, object);
      
      final index = objects.indexWhere((obj) => obj.id == id);
      if (index != -1) {
        objects[index] = updatedObject;
      }
      
      final allIndex = _allObjects.indexWhere((obj) => obj.id == id);
      if (allIndex != -1) {
        _allObjects[allIndex] = updatedObject;
      }
      
      selectedObject.value = updatedObject;
      
      Get.snackbar(
        'Success',
        'Object updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update object: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteObject(String id) async {
    final objectToDelete = objects.firstWhere((obj) => obj.id == id);
    final objectIndex = objects.indexOf(objectToDelete);
    
    objects.removeWhere((obj) => obj.id == id);
    _allObjects.removeWhere((obj) => obj.id == id);
    
    try {
      await _apiService.deleteObject(id);
      
      Get.snackbar(
        'Success',
        'Object deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.back();
    } catch (e) {
      objects.insert(objectIndex, objectToDelete);
      _allObjects.insert(objectIndex, objectToDelete);
      
      Get.snackbar(
        'Error',
        'Failed to delete object: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearObjects() {
    objects.clear();
    _allObjects.clear();
    _currentPage = 0;
  }
}