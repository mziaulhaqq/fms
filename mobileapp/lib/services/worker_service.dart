import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/worker.dart';

class WorkerService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Worker>> getAllWorkers() async {
    try {
      final response = await _apiClient.get(ApiConfig.workers);
      final List<dynamic> data = response.data;
      return data.map((json) => Worker.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load workers: $e');
    }
  }

  Future<Worker> getWorkerById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.workers}/$id');
      return Worker.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load worker: $e');
    }
  }

  Future<Worker> createWorker(Worker worker) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.workers,
        data: worker.toJsonRequest(),
      );
      return Worker.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create worker: $e');
    }
  }

  Future<Worker> updateWorker(int id, Worker worker) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.workers}/$id',
        data: worker.toJsonRequest(),
      );
      return Worker.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update worker: $e');
    }
  }

  Future<void> deleteWorker(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.workers}/$id');
    } catch (e) {
      throw Exception('Failed to delete worker: $e');
    }
  }
}
