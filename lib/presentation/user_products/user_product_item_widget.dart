import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/products_provider.dart';
import 'package:shopit/presentation/navigation/routes.dart';

class UserProductItemWidget extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItemWidget({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);

    return Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
        Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoute.ADD_EDIT_USER_PRODUCT,
            arguments: id,
          ),
          color: Theme.of(context).primaryColor,
          icon: Icon(Icons.edit_rounded),
        ),
        IconButton(
          onPressed: () async {
            try {
              await productsProvider.delete(id);
            } catch (error) {
              messengerState.showSnackBar(SnackBar(
                content: Text(error.toString()),
              ));
            }
          },
          color: Theme.of(context).errorColor,
          icon: Icon(Icons.delete_forever_rounded),
        )
      ],
    );
  }
}
