import 'package:favorite_places/providers/user_plase.dart';
import 'package:favorite_places/screens/add_places.dart';
import 'package:favorite_places/widgets/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class placeScreen extends ConsumerStatefulWidget {
  const placeScreen({super.key});
  @override
  ConsumerState<placeScreen> createState() {
    return placeScreenState();
  }
}

class placeScreenState extends ConsumerState<placeScreen> {
  late Future<void> _placeFuture;
  @override
  void initState() {
    super.initState();
    _placeFuture = ref.read(UserPlaseProvider.notifier).loadPlace();
  }

  Widget build(BuildContext context) {
    final userPlaces = ref.watch(UserPlaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddPlacesSereen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
            future: _placeFuture,
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : PlacesList(places: userPlaces)),
      ),
    );
  }
}




//  Widget build(BuildContext context, WidgetRef ref) {
//     final userPlaces = ref.watch(UserPlaseProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Places'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => const AddPlacesSereen(),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: FutureBuilder(
//             future: future,
//             builder: (context, snapshot) =>
//                 snapshot.connectionState == ConnectionState.waiting
//                     ? const Center(
//                         child: CircularProgressIndicator(),
//                       )
//                     : PlacesList(places: userPlaces)),
//       ),
//     );
//   }