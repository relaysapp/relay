import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("홈화면"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Relay 진행 중인 방에 입장하는 코드
            },
            child: const Text('진행 중인 릴레이 방 입장'),
          ),
          ElevatedButton(
            onPressed: () {
              // 완료된 릴레이를 보는 코드
            },
            child: const Text('완료된 릴레이 열람'),
          ),
          ElevatedButton(
            onPressed: () {
              // 커뮤니티를 보는 코드
            },
            child: const Text('커뮤니티 열람'),
          ),
        ],
      ),
    );
  }
}
