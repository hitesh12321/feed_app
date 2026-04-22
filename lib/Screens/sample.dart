// import 'package:andaz/Providers/posts_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class Sample extends ConsumerStatefulWidget {
//   const Sample({super.key});

//   @override
//   ConsumerState<Sample> createState() => _SampleState();
// }

// class _SampleState extends ConsumerState<Sample> {
//   @override
//   Widget build(BuildContext context) {
//     final provider = ref.watch(feedProvider );
//     return Scaffold(
//       body: Center(
//         child: provider.when(
//           data: (value) => ListView.builder(
//             itemBuilder: (context, index) => Text(value[index].id ?? 'No ID'),
//             itemCount: value.length,
//           ),
//           error: (error, stack) => Text(error.toString()),
//           loading: () => const CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
// }
