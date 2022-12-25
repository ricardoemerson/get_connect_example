import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_connect_example/models/user_model.dart';

class UserRepository {
  final restClient = GetConnect(timeout: const Duration(milliseconds: 600));

  UserRepository() {
    restClient.httpClient.baseUrl = 'http://192.168.1.107:8080';
    // restClient.httpClient.maxAuthRetries = 3;

    restClient.httpClient.addAuthenticator<Object?>((request) async {
      final response = await restClient.post('/auth', {
        'email': 'ricardo_emerson@yahoo.com.br',
        'password': '123',
      });

      if (!response.hasError) {
        final accessToken = response.body['access_token'];
        final type = response.body['type'];

        if (accessToken != null) {
          request.headers['authorization'] = '$type $accessToken';
        }
      }

      return request;
    });

    restClient.httpClient.addRequestModifier<Object?>((request) {
      log('URL: ${request.url.toString()}');
      request.headers['start-time'] = DateTime.now().toIso8601String();

      return request;
    });

    restClient.httpClient.addResponseModifier((request, response) {
      response.headers?['end-time'] = DateTime.now().toIso8601String();

      return response;
    });

    // restClient.httpClient.errorSafety = false;
  }

  Future<List<UserModel>> findAll() async {
    var response = await restClient.get('/users');

    if (response.hasError) {
      throw Exception('Erro ao buscar usuários (${response.statusText})');
    }

    log(response.request?.headers['start-time'] ?? '');
    log(response.headers?['end-time'] ?? '');

    return response.body.map<UserModel>((user) => UserModel.fromMap(user)).toList();
  }

  Future<void> save(UserModel userModel) async {
    final response = await restClient.post('/users', userModel.toMap());

    if (response.hasError) {
      throw Exception('Erro ao salvar usuário (${response.statusText})');
    }
  }

  Future<void> update(UserModel userModel) async {
    final response = await restClient.put('/users/${userModel.id}', userModel.toMap());

    if (response.hasError) {
      throw Exception('Erro ao atualizar usuário (${response.statusText})');
    }
  }

  Future<void> delete(UserModel userModel) async {
    final response = await restClient.delete('/users/${userModel.id}');

    if (response.hasError) {
      throw Exception('Erro ao remover usuário (${response.statusText})');
    }
  }
}
