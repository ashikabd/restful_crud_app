import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/object_controller.dart';
import '../../models/api_object.dart';

class ObjectFormScreen extends StatefulWidget {
  final ApiObject? object;

  const ObjectFormScreen({Key? key, this.object}) : super(key: key);

  @override
  State<ObjectFormScreen> createState() => _ObjectFormScreenState();
}

class _ObjectFormScreenState extends State<ObjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dataController = TextEditingController();

  bool get isEditMode => widget.object != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.object!.name;
      if (widget.object!.data != null) {
        _dataController.text = const JsonEncoder.withIndent('  ')
            .convert(widget.object!.data);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _parseJsonData(String jsonString) {
    if (jsonString.trim().isEmpty) return null;

    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('Data must be a JSON object');
    } catch (e) {
      throw FormatException('Invalid JSON: ${e.toString()}');
    }
  }

  void _saveObject() {
    if (_formKey.currentState!.validate()) {
      final ObjectController controller = Get.find<ObjectController>();

      try {
        final data = _parseJsonData(_dataController.text);

        final object = ApiObject(
          id: widget.object?.id,
          name: _nameController.text.trim(),
          data: data,
        );

        if (isEditMode && widget.object!.id != null) {
          controller.updateObject(widget.object!.id!, object);
        } else {
          controller.createObject(object);
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Invalid data format: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ObjectController controller = Get.find<ObjectController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Object' : 'Create Object'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'Enter object name',
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataController,
                    decoration: const InputDecoration(
                      labelText: 'Data (JSON)',
                      hintText: '{"key1": "value1", "key2": "value2"}',
                      prefixIcon: Icon(Icons.code),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 10,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        try {
                          _parseJsonData(value);
                        } catch (e) {
                          return e.toString();
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter valid JSON object (optional). Example:\n{"color": "red", "capacity": 256}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveObject,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isEditMode ? 'Update Object' : 'Create Object',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (isEditMode) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}