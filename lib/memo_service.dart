import 'dart:convert';

import 'package:flutter/material.dart';

import 'main.dart';

// Memo 데이터의 형식을 정해줍니다. 추후 isPinned, updatedAt 등의 정보도 저장할 수 있습니다.
class Memo {
  Memo({
    required this.content,
    this.isPinned = false,
    this.updatedAt,
  });

  String content;
  bool isPinned;
  DateTime? updatedAt; // 데이터 형식에 ?는 null 값을 허용

  Map toJson() {
    return {
      'content': content,
      'isPinned': isPinned,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Memo.fromJson(json) {
    return Memo(
      content: json['content'],
      isPinned: json['isPinned'] ?? false,
      updatedAt:
          json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']),
    );
  }
}

// Memo 데이터는 모두 여기서 관리
class MemoService extends ChangeNotifier {
  // 생성자
  MemoService() {
    // 처음 페이지가 불러올 때 shared_preferences에서 객체 데이터로 불러옴
    loadMemoList();
  }

  List<Memo> memoList = [
    Memo(content: '장보기 목록: 사과, 양파'), // 더미(dummy) 데이터
    Memo(content: '새 메모'), // 더미(dummy) 데이터
  ];

  createMemo({required String content}) {
    Memo memo = Memo(content: content, updatedAt: DateTime.now());
    memoList.add(memo);
    notifyListeners(); // Consumer<MemoService>의 builder 부분을 호출해서 화면 새로고침
    saveMemoList();
  }

  updateMemo({required int index, required String content}) {
    Memo memo = memoList[index];
    memo.content = content;

    memo.updatedAt = DateTime.now();
    notifyListeners();

    // 수정된 데이터를 String 타입으로 shared_preferences에 저장
    saveMemoList();
  }

  updatePinMemo({required int index}) {
    Memo memo = memoList[index];
    memo.isPinned = !memo.isPinned;
    memoList = [
      ...memoList.where((element) => element.isPinned),
      ...memoList.where((element) => !element.isPinned)
    ];
    notifyListeners();

    // 수정된 데이터를 String 타입으로 shared_preferences에 저장
    saveMemoList();
  }

  deleteMemo({required int index}) {
    memoList.removeAt(index);
    notifyListeners();

    // 수정된 데이터를 String 타입으로 shared_preferences에 저장
    saveMemoList();
  }

  saveMemoList() {
    List memoJsonList = memoList.map((memo) => memo.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(memoJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('memoList', jsonString);
  }

  loadMemoList() {
    String? jsonString = prefs.getString('memoList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List memoJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    memoList = memoJsonList.map((json) => Memo.fromJson(json)).toList();
  }
}
