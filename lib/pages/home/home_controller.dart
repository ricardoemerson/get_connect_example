import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_connect_example/models/user_model.dart';
import 'package:get_connect_example/repositories/user_repository.dart';

class HomeController extends GetxController with StateMixin<List<UserModel>> {
  final UserRepository _repository;

  HomeController({
    required UserRepository repository,
  }) : _repository = repository;

  @override
  void onReady() {
    _findAll();

    super.onReady();
  }

  Future<void> _findAll() async {
    try {
      change([], status: RxStatus.loading());

      final users = await _repository.findAll();

      var statusResponse = RxStatus.success();

      if (users.isEmpty) {
        statusResponse = RxStatus.empty();
      }

      change(users, status: statusResponse);
    } catch (e, s) {
      log('Erro ao buscar usuários', error: e, stackTrace: s);
      change(state, status: RxStatus.error());
    }
  }

  Future<void> register() async {
    try {
      final user = UserModel(
        name: 'Ricardo Emerson',
        email: 'ricardo_emerson@yahoo.com.br',
        password: '123',
      );

      await _repository.save(user);

      _findAll();
    } catch (e, s) {
      log('Erro ao salvar usuário', error: e, stackTrace: s);

      Get.snackbar('Erro', 'Erro ao salvar usuário.');
    }
  }

  Future<void> updateUser(UserModel userModel) async {
    try {
      userModel.name = 'Ricardo Jardim';
      userModel.email = 'ricardo_emerson@hotmail.com';

      await _repository.update(userModel);

      _findAll();
    } catch (e, s) {
      log('Erro ao atualizar usuário', error: e, stackTrace: s);

      Get.snackbar('Erro', 'Erro ao atualizar usuário.');
    }
  }

  Future<void> delete(UserModel userModel) async {
    try {
      await _repository.delete(userModel);

      _findAll();

      Get.snackbar('Sucesso', 'Usuário removido com sucesso.');
    } catch (e, s) {
      log('Erro ao remover usuário', error: e, stackTrace: s);

      Get.snackbar('Erro', 'Erro ao remover usuário.');
    }
  }
}
