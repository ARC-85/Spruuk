import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/models/user_model.dart';
import 'package:spruuk/providers/authentication_provider.dart';
import 'package:spruuk/providers/user_provider.dart';

class MyVendorCard extends ConsumerStatefulWidget {
  const MyVendorCard(
      {Key? key,
      required this.vendorUser,
      required this.user,
      required this.listIndex})
      : super(key: key);
  final UserModel vendorUser;
  final UserModel user;
  final int listIndex;

  @override
  ConsumerState<MyVendorCard> createState() => _MyVendorCard();
}

class _MyVendorCard extends ConsumerState<MyVendorCard> {
  List<UserModel> allVendors = [];
  UserModel? currentUser1;
  bool favourited = false;
  bool? firstBuild;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authData = ref.watch(fireBaseAuthProvider);
    ref
        .watch(userProvider)
        .getCurrentUserData(authData.currentUser!.uid)
        .then((value) {
      setState(() {
        currentUser1 = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {}

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    allVendors = ref.watch(userProvider).allUsers!;
    final vendorUser = widget.vendorUser;
    final user = widget.user;
    final listIndex = widget.listIndex;

    if (currentUser1 != null && currentUser1!.userVendorFavourites != null) {
      favourited = currentUser1!.userVendorFavourites!
          .any((_vendorId) => _vendorId == vendorUser.uid);
    } else {
      _refresh();
    }

    return Dismissible(
        // Used to delete items withing the ListView, as suggested https://stackoverflow.com/questions/55142992/flutter-delete-item-from-listview
        key: UniqueKey(),
        onDismissed: (direction) {
          ref.read(userProvider).removeVendorFavouriteToClient(vendorUser!.uid);
        },
        child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 95, 1).withOpacity(0.6),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                            width: screenDimensions.width * 0.2,
                            height: screenDimensions.width * 0.2,
                            child: vendorUser.userImage != null
                                ? Image.network(vendorUser.userImage!,
                                    fit: BoxFit.cover)
                                : const CircleAvatar(
                                    radius: 60,
                                    backgroundImage: AssetImage(
                                        "assets/images/circular_avatar.png"))),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                                "${vendorUser.firstName} ${vendorUser.lastName}"!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              vendorUser.email,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        )
                      ]),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/ClientVendorDetailsScreen',
                      arguments: vendorUser.uid);
                })));
  }
}
